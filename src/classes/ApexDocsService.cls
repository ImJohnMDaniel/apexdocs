/**
 *  Service to handle all processing requests for the ApexDocs application. This class is responsible
 *      for parsing the Apex Class and organizing the information
 *      for display in the "docs" section.
 *
 *  This is also a working example of the link tag within a comment.  Here, I am
 *      linking to the {@link ApexDocsUtils} class.
 *  The link should be just before this line
 *
 *  @author John M. Daniel
 * @date 7 MARCH 2015
 * @see IApexDocsService
 * @see IFile
 * @see ClassLinkModel
 * @since 1.0
 * @version 1.0
 */
public with sharing class ApexDocsService
{
    private static IApexDocsService service()
    {
    	return (IApexDocsService) Application.Service.newInstance(IApexDocsService.class);
    }

    public static IFile getClass(final id classId)
    {
        return service().getClass( classId );
    }

    /**
     *  This is also a working example of the link tag within a method comment.  Here, I am
     *      linking to the {@link ApexDocsUtils} class.
     *  The link should be just before this line
     */
    public static IFile getClass(final string className)
    {
        return service().getClass( className );
    }

    public static list<IFile> findAllFiles()
    {
        return service().findAllFiles();
    }

    public static list<ClassLinkModel> findKnownSubClassesForFile(final IFile model)
    {
        return service().findKnownSubClassesForFile( model );
    }

    public static list<ClassLinkModel> findKnownImplementorsForFile(final IFile model)
    {
        return service().findKnownImplementorsForFile( model );
    }

    public static list<ClassLinkModel> findKnownThrowersOfExceptionForFile(final IFile model)
    {
        return service().findKnownThrowersOfExceptionForFile( model );
    }

    public static void documentAll()
    {
        service().documentAll();
    }

    public static void document(final IFile model)
    {
        service().document( model );
    }

    public static void reset()
    {
        service().reset();
    }
}