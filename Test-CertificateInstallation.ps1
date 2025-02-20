        ##TODO <Detection Script>
          $CertPath = "$dirFiles\Certificates"  # Change this to your actual folder path

          # Define the Path of the Certificate store you want to test. 
          $TargetCerts = Get-ChildItem -Path "Cert:\LocalMachine\root"
          $TargetThumbprints = $TargetCerts | Select-Object -ExpandProperty Thumbprint
          
          # Get all .cer and .crt files from the folder
          #$CertFiles = Get-ChildItem -Path $CertPath -Include "*.cer","*.crt" -File
          $CertFiles = Get-ChildItem -Path $CertPath | where-object { $_.extension -eq ".cer" -or $_.extension -eq ".crt" }
          
          # Initialize arrays to track valid and invalid certificates
          $ValidCerts = @()
          $InvalidCerts = @()
          
          # Loop through each certificate file
          foreach ($CertFile in $CertFiles) {
              try {
                  # Get certificate details without installing
                  $Cert = Get-PfxCertificate -FilePath $CertFile.FullName
          
                  # Check if the thumbprint exists in the root store
                  if ($Cert.Thumbprint -in $TargetThumbprints) {
                      $ValidCerts += $Cert
                  } else {
                      $InvalidCerts += $Cert
                  }
              } catch {
                  Write-Log "Error processing $($CertFile.FullName): $_"
                  $InvalidCerts += $CertFile.Name  # Store the filename if the cert couldn't be read
              }
          }
          
          # Log successfully validated certificates
          if ($ValidCerts) {
              $ValidCertList = $ValidCerts | ForEach-Object { "$($_.Subject) [$($_.Thumbprint)]" }
              Write-Log "The following certificates were successfully verified in the root store:`n$($ValidCertList -join "`n")"
          }
          
          # Log non-compliant certificates and determine SCCM compliance
          if ($InvalidCerts) {
              $InvalidCertList = $InvalidCerts | ForEach-Object { 
                  if ($_ -is [string]) { $_ } else { "$($_.Subject) [$($_.Thumbprint)]" }
              }
              Write-Log "The following certificates were NOT found in the root store:`n$($InvalidCertList -join "`n")"
              Write-Log "Found Non-Compliant Certs!"
              #exit 1  # Non-compliant for SCCM
          } else {
              Write-Log "All Certs Successfully Installed"
              $CertCompliance = $true
              #exit 0  # Compliant for SCCM
          }
