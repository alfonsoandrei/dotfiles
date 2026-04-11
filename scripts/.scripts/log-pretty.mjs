#!/usr/bin/env node
import { spawn } from 'child_process'
import { createInterface } from 'readline'

const file = process.argv[2] ?? '/tmp/scm-debug.log'

const COLORS = {
  reset:   '\x1b[0m',
  bold:    '\x1b[1m',
  dim:     '\x1b[2m',
  debug:   '\x1b[36m',   // cyan
  info:    '\x1b[32m',   // green
  warn:    '\x1b[33m',   // yellow
  error:   '\x1b[31m',   // red
  gray:    '\x1b[90m',
  white:   '\x1b[97m',
  magenta: '\x1b[35m',
}

const LEVEL_COLORS = {
  debug: COLORS.debug,
  info:  COLORS.info,
  warn:  COLORS.warn,
  error: COLORS.error,
}

function colorLevel(level = 'info') {
  const c = LEVEL_COLORS[level] ?? COLORS.white
  return `${c}${COLORS.bold}${level.toUpperCase().padEnd(5)}${COLORS.reset}`
}

function formatTime(ts) {
  if (!ts) return ''
  // Show only HH:MM:SS.mmm
  const d = new Date(ts)
  return `${COLORS.gray}${d.toTimeString().slice(0, 8)}.${String(d.getMilliseconds()).padStart(3, '0')}${COLORS.reset}`
}

function formatLine(raw) {
  let obj
  try {
    obj = JSON.parse(raw)
  } catch {
    // Not JSON — print as-is
    return `${COLORS.dim}${raw}${COLORS.reset}`
  }

  const { level, timestamp, message, service, env, caller, stacktrace, ...rest } = obj

  const parts = [
    formatTime(timestamp),
    colorLevel(level),
    `${COLORS.bold}${COLORS.white}${message}${COLORS.reset}`,
  ]

  // Highlight key fields inline
  const inline = ['call_id', 'call_uuid', 'intent', 'operation', 'trace_id', 'member', 'stream', 'group']
  const inlineFields = []
  const remaining = {}

  for (const [k, v] of Object.entries(rest)) {
    if (inline.includes(k)) {
      inlineFields.push(`${COLORS.magenta}${k}${COLORS.reset}=${COLORS.white}${v}${COLORS.reset}`)
    } else {
      remaining[k] = v
    }
  }

  if (inlineFields.length) parts.push(inlineFields.join(' '))

  if (caller) parts.push(`${COLORS.gray}(${caller})${COLORS.reset}`)

  let out = parts.join('  ')

  // Pretty-print remaining fields on next line if any
  if (Object.keys(remaining).length) {
    out += `\n  ${COLORS.dim}${JSON.stringify(remaining, null, 2).split('\n').join('\n  ')}${COLORS.reset}`
  }

  if (stacktrace) {
    out += `\n  ${COLORS.error}${stacktrace}${COLORS.reset}`
  }

  return out
}

console.log(`${COLORS.gray}Tailing ${file} ...${COLORS.reset}\n`)

const tail = spawn('tail', ['-f', '-n', '0', file])
const rl = createInterface({ input: tail.stdout })

rl.on('line', line => {
  if (line.trim()) console.log(formatLine(line))
})

tail.stderr.on('data', d => process.stderr.write(d))
tail.on('close', () => process.exit(0))
process.on('SIGINT', () => { tail.kill(); process.exit(0) })
