$logFileExists = Get-EventLog -List | Where-Object { $_.LogDisplayName -eq "CustomLog" }

if (-not $logFileExists) {
	New-EventLog -LogName "CustomLog" -Source "CustomLog"
	Write-EventLog -LogName "CustomLog" -Source "CustomLog" -EntryType Information -EventId 1 -Message "CustomLog event log created"
}
