/**
 *  Utility to parse ApexClass objects to a IFile based model
 *  @see IFile
 */
public
 class Sample3
{
    private static list<string> accessModifierList { get; set; }
    private static string EXTENDS_KEYWORD_STRING = ' extends ';
    private static string IMPLEMENTS_KEYWORD_STRING = ' implements ';

    static
    {
        accessModifierList = new list<string>();

        // These next strings are added to the list in this manner to ensure that
        // they are not accidently picked up as "methods" because they are
        // "access modifier scope" words
        accessModifierList.add('glo'+'bal');
        accessModifierList.add('pub'+'lic');
        accessModifierList.add('prot'+'ected');
        accessModifierList.add('priv'+'ate');
        accessModifierList.add('webse'+'rvice');
    }

    private list<ApexClass> m_apexClasses = new list<ApexClass>();
    private boolean m_isPrivateConstructsIncludedInModel = false;
    private list<IFile> m_models = new list<IFile>();

    /*
     *  Private constructor.
     */
    private Sample3()
    {

    }

    /**
     *  Main Constructor
     *  @param Apex classes to be parsed
     */
    public Sample3(list<ApexClass> apexClasses)
    {
        this.m_apexClasses = apexClasses;
    }

        /**
     *  Main parsing routine.  Method will organize and parse
     *  all ApexClass records into resulting list of IFile models
     *  @return list of {@link IFile} records
     */
    public list<IFile> parse()
    {
        for (ApexClass clazz : m_apexClasses)
        {
            m_models.add( (new Sample3.ParsingUtil(clazz, this)).parse() );
        }

        return m_models;
    }

    /**
     *  Nested class responsible for parsing single ApexClass
     */
    private class ParsingUtil
    {
        private ParsingUtil(final ApexClass clazz, Sample3 apexClassesParserInstance)
        {

        }

        /**
         *  Method will begin parsing tasks on the class.
         *  @return {@link IFile} model representation of the ApexClass
         */
        private IFile parse()
        {

            return null;
        }
    }

    public class ApexClassesParserException extends Exception { }

    public
    interface ScratchInterface
    {
    }

}