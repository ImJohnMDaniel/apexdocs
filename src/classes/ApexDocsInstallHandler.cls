global class ApexDocsInstallHandler
    implements InstallHandler
{
    global void onInstall(InstallContext context)
    {
    	ApexDocsService.initializeEnvironment();
        ApexDocsService.reset();
        ApexDocsService.documentAll();
    }
}