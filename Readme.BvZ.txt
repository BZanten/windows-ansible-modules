

https://docs.ansible.com/ansible/2.9/dev_guide/developing_modules_general_windows.html
#AnsibleRequires -CSharpUtil Ansible.Basic
This will import the module_util at ./lib/ansible/module_utils/csharp/Ansible.Basic.cs and automatically load the types in the executing process. C# module utils can reference each other and be loaded together by adding the following line to the using statements at the top of the util:
 (bvz ->  C:\GIT\ansible\lib\ansible\module_utils\csharp\Ansible.Basic.cs )


testing manually:
ansible mikmak.lng.local -m win_cmdlet -a "cmdletnoun=dnsclient additionalparams='-InterfaceIndex 20' parameter='ConnectionSpecificSuffix' value='lng.local'"
ansible mikmak.lng.local -m win_cmdlet -a "cmdletnoun=dnsclient additionalparams='-InterfaceIndex 20' parameter='ConnectionSpecificSuffix' value='lng.local'" --check -D

Testing other module:
ansible mikmak.lng.local -m win_environment -a "name=OneDrive level=user state=present value='C:\\Users\BenBeheer\OneDrive'"
ansible mikmak.lng.local -m win_environment -a "name=OneDrive level=user state=present value='C:\\Users\BenBeheer\OneDrive'" --check -D

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$module  object :

CheckMode       : False
DebugMode       : False
DiffMode        : False
KeepRemoteFiles : False
ModuleName      : win_cmdlet
NoLog           : False
Verbosity       : 0
AnsibleVersion  : 2.9.6
Tmpdir          : C:\Users\benbeheer\AppData\Local\Temp\ansible-moduletmp-132601917352181255-1352616750
Diff            : {}
Params          : {type, value, cmdletnoun, debug...}
Result          : {[changed, False], [invocation, System.Collections.Hashtable]}


   TypeName: Ansible.Basic.AnsibleModule

Name            MemberType Definition                                                                                   
----            ---------- ----------                                                                                   
Debug           Method     void Debug(string message)                                                                   
Deprecate       Method     void Deprecate(string message, string version)                                               
Equals          Method     bool Equals(System.Object obj)                                                               
ExitJson        Method     void ExitJson()                                                                              
FailJson        Method     void FailJson(string message), void FailJson(string message, System.Management.Automation.ErrorRecord psErrorRecord), void FailJson(string message, System.Exception exception)
GetHashCode     Method     int GetHashCode()                                                                            
GetType         Method     type GetType()                                                                               
LogEvent        Method     void LogEvent(string message, System.Diagnostics.EventLogEntryType logEntryType, bool sanitise)
ToString        Method     string ToString()                                                                            
Warn            Method     void Warn(string message)                                                                    
AnsibleVersion  Property   string AnsibleVersion {get;}                                                                 
CheckMode       Property   bool CheckMode {get;}                                                                        
DebugMode       Property   bool DebugMode {get;}                                                                        
Diff            Property   System.Collections.Generic.Dictionary[string,System.Object] Diff {get;set;}                  
DiffMode        Property   bool DiffMode {get;}                                                                         
KeepRemoteFiles Property   bool KeepRemoteFiles {get;}                                                                  
ModuleName      Property   string ModuleName {get;}                                                                     
NoLog           Property   bool NoLog {get;}                                                                            
Params          Property   System.Collections.IDictionary Params {get;set;}                                             
Result          Property   System.Collections.Generic.Dictionary[string,System.Object] Result {get;set;}                
Tmpdir          Property   string Tmpdir {get;}                                                                         
Verbosity       Property   int Verbosity {get;}                                                                         
