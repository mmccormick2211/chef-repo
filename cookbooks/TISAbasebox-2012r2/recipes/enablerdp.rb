#
# Cookbook:: TISAbasebox-2012r2
# Recipe:: enablerdp
#
# Copyright:: 2017, The Authors, All Rights Reserved.
# Enables remote desktop access to the server

powershell_script "enable-remote-desktop" do
    guard_interpreter :powershell_script
    code <<-EOH
      Set-ItemProperty -Path 'HKLM:\\System\\CurrentControlSet\\Control\\Terminal Server' -name "fDenyTSConnections" -Value 0
      Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
      Set-ItemProperty -Path 'HKLM:\\System\\CurrentControlSet\\Control\\Terminal Server\\WinStations\\RDP-Tcp' -name "UserAuthentication" -Value 1
      eventcreate /t INFORMATION /ID 2 /L APPLICATION /SO "Chef-Client" /D "Enabled Remote Desktop access"
    EOH
    only_if <<-EOH
      if ((Get-ItemProperty -Path 'HKLM:\\System\\CurrentControlSet\\Control\\Terminal Server').fDenyTSConnections -ne "0") {
        $true
      } elseif ((Get-NetFirewallRule -Name "RemoteDesktop-UserMode-In-TCP").Enabled -ne "True") {
        $true
      } elseif ((Get-ItemProperty -Path 'HKLM:\\System\\CurrentControlSet\\Control\\Terminal Server\\WinStations\\RDP-Tcp').UserAuthentication -ne "1") {
        $true
      } else {
        $false
      }
    EOH
  end