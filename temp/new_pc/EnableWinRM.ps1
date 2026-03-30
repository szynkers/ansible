# 1. Tworzymy certyfikat self-signed dla WinRM
$hostname = "$($env:COMPUTERNAME).firma.local"   # dostosuj domenę DNS
$cert = New-SelfSignedCertificate `
    -DnsName $hostname `
    -CertStoreLocation "Cert:\LocalMachine\My"

# 2. Włączamy WinRM jeśli nie włączony
winrm quickconfig -q

# 3. Tworzymy listener HTTPS na 5986
winrm delete winrm/config/Listener?Address=*+Transport=HTTPS 2>$null
winrm create winrm/config/Listener?Address=*+Transport=HTTPS `
    "@{Hostname='$hostname'; CertificateThumbprint='$($cert.Thumbprint)'}"

# 4. Twardo wyłączamy niezaszyfrowaną komunikację
winrm set winrm/config/service '@{AllowUnencrypted="false"}'

# 5. Ustawiamy mechanizmy uwierzytelniania
#    (na etapie workgroup zwykle NTLM; Basic opcjonalnie, ale już w HTTPS)
winrm set winrm/config/service/auth '@{Kerberos="true";NTLM="true";Basic="true"}'

# 6. Firewall – otwieramy tylko 5986, opcjonalnie z ograniczeniem źródłowych IP
netsh advfirewall firewall add rule name="WinRM HTTPS" `
    dir=in action=allow protocol=TCP localport=5986
	
# 7. Po dołączeniu do domeny
# winrm set winrm/config/service/auth '@{Basic="false"}'
