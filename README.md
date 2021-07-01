# First Alert
First Alert is a permanent WMI subscription that monitors for the execution of vssadmin and bcdedit. When either of them are executed, the parent process is terminated. The implementation of First Alert will persist beyond a reboot and will require removal when the capability is no longer desired to be run. 

# Notes
At present, any legitimate use of vssadmin or bcdedit will be perceived as malicious and will be terminated
