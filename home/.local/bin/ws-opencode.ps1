#!/usr/bin/env pwsh
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    $Args
)

$opencodePath = "/home/jon/.opencode/bin/opencode"

$command = "$opencodePath $Args"

wsl bash -lc "$command"