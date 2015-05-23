public interface IApexDocsService
{
    IFile getClass(final id classId);
    IFile getClass(final string className);
    list<IFile> findAllFiles();
    list<ClassLinkModel> findKnownSubClassesForFile(final IFile model);
    list<ClassLinkModel> findKnownImplementorsForFile(final IFile model);
    list<ClassLinkModel> findKnownThrowersOfExceptionForFile(final IFile model);
    void documentAll();
    IFile document(final ApexClass clazz);
    IFile document(final IFile model);
    void reset();
}