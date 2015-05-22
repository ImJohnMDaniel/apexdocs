global class ApexDocsInstallHandler
    implements InstallHandler
{
    global void onInstall(InstallContext context)
    {
        ApexDocsService.reset();
        ApexDocsService.documentAll();
    }
}