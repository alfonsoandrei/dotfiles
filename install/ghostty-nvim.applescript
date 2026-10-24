-- Opens files in a new Ghostty window running nvim-lite, without a shell.
-- install/macos.sh compiles this to ~/Applications/Ghostty Nvim.app and makes it the plain-text handler.

on run
	openInNvim({})
end run

on open theFiles
	openInNvim(theFiles)
end open

on openInNvim(theFiles)
	set cmd to "/opt/homebrew/bin/nvim -p"
	set workDir to POSIX path of (path to home folder)
	repeat with f in theFiles
		set cmd to cmd & " " & quoted form of POSIX path of f
	end repeat
	if (count of theFiles) > 0 then
		set workDir to do shell script "dirname " & quoted form of POSIX path of (item 1 of theFiles)
	end if

	set homeDir to POSIX path of (path to home folder)
	set envVars to {"NVIM_APPNAME=nvim-lite", "PATH=/opt/homebrew/bin:" & homeDir & ".local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"}

	tell application "Ghostty"
		new window with configuration {command:cmd, initial working directory:workDir, environment variables:envVars}
		activate
	end tell
end openInNvim
