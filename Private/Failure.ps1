function Failure {
$global:helpme = $body
$global:helpmoref = $moref
$global:result = $_.Exception.Response.GetResponseStream()
$global:reader = New-Object System.IO.StreamReader($global:result)
$global:responseBody = $global:reader.ReadToEnd();
Write-Host -BackgroundColor:Black -ForegroundColor:Red "Status: A system exception was caught."
Write-Host -BackgroundColor:Black -ForegroundColor:Red $global:responsebody
Write-Host -BackgroundColor:Black -ForegroundColor:Red "The request body has been saved to `$global:helpme"
break
}
