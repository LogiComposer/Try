##############################################################################
## Original version @ https://gallery.technet.microsoft.com/scriptcenter/Powershell-Script-for-13a551b3
## Updated: 5/26/2015, Version 2.0, By: Sangamesh (sangameshb@yahoo) on 5/26/2015 
## Updated: 12/16/2019, By: Niyakiy (jonny.niyakiy@gmail.com) on 12/16/2019
##############################################################################

param (
    [string]$url,
    [switch]$t,
    [switch]$help
)
  
  $max = 300
  
  $index = 0
  while($index -lt $max -or $max -eq -1){
  	  
  	  $index = $index + 1
  	  
	  $result = @() 

	  $time = try{
		$request = $null
		
		$result1 = Measure-Command { $request = Invoke-WebRequest -Uri $url -Verbose:$false} 
		$result1.TotalMilliseconds
	  } 
	  catch
	  {
		   <# If the request generated an exception (i.e.: 500 server
		   error or 404 not found), we can pull the status code from the
		   Exception.Response property #>
		   $request = $_.Exception.Response
		   $time = -1
	  }  
	  $result += [PSCustomObject] @{
		  Time = Get-Date;
		  Uri = $uri;
		  StatusCode = [int] $request.StatusCode;
		  StatusDescription = $request.StatusDescription;
		  ResponseLength = $request.RawContentLength;
		  TimeTaken =  $time; 
	  }

    If ([int] $request.StatusCode -gt 0 -And [int] $request.StatusCode -lt 300) {
      exit 0
    }
	  	
		Write-Host -NoNewline "."
	  
	  Start-Sleep -s 1

  }

Write-Host "Timeout waiting for web server."
