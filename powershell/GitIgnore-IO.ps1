# from https://github.com/joeblau/gitignore.io
#For PowerShell v3
Function gig {
  param(
    [Parameter(Mandatory=$true)]
    [string[]]$list
  )
  $params = $list -join ","
  # Invoke-WebRequest -Uri "https://www.gitignore.io/api/$params" | select -ExpandProperty content | Out-File -FilePath $(Join-Path -path $pwd -ChildPath ".gitignore") -Encoding ascii
  Invoke-WebRequest -Uri "https://www.gitignore.io/api/$params" | select -ExpandProperty content
}
