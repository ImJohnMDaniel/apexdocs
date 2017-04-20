/**
 *  This is a "command line interface" to the ApexDocs tool and represents the functions
 *  that are exposed to subscriber's org default namespace.  The purpose of this class
 *  is to expose various functions that could be used for debugging purposes and also
 *  leaving a "design approach" to eventually open up true command line tasks like
 *  a task that is part of a continous integration build to document and download all
 *  classes via the Force.com CLI tool ({@link https://force-cli.heroku.com/}).
 *  @since 1.0
 *  @author John M. Daniel
 */
global class CLI
{
    /**
     * This method will perform a single file documentation.  The output of this command
     * is a JSON serialized representation of the class that was just documented.  The main
     * purpose of this method is provide a way to easily capture in a serialized form
     * what the documented model looks like.  This can then be compared to the actual Apex class
     * file for analysis.
     *
     * @param apexClassName - string name of the ApexClass that should be documented.
     * @return JSON Serialized version of the documented class.
     */
    global static string document(final string apexClassName)
    {
        string output = null;

        list<ApexClass> classes = ApexClassesSelector.newInstance().selectByName( new set<string>{ apexClassName });

        if ( ! classes.isEmpty() )
        {
            IFile classAsIFile = ApexDocsService.document( classes[0] );

            output = classAsIFile != null ? JSON.SerializePretty( classAsIFile ) : null;
        }
        else
        {
            throw new CLIException('Unable to find class named '+apexClassName);
        }

        return output;
    }

    /**
     *  Method used to document all Apex classes in the default namespace of the org.
     */
    global static void documentAll()
    {
        ApexDocsService.documentAll();
    }

    /**
     *  Method used to reset all data regarding previously documented class files.
     */
    global static void reset()
    {
        ApexDocsService.reset();
    }

    global static string find(final string apexClassName)
    {
        string output = null;

        try
        {
            output = JSON.SerializePretty(ApexDocsService.getClass(apexClassName));
        }
        catch (ApexDocsServiceException adse)
        {
            throw new CLIException('Error while trying to find class named '+apexClassName);
        }

        return output;
    }

    global static string findRawJsonModelRepresentation(final string apexClassName)
    {
        string output = null;

        try
        {
            output = CodeInfosSelector.newInstance().selectByApexClassName( new set<String>{ apexClassName } )[0].JSON__c;
        }
        catch (Exception e)
        {
            throw new CLIException('Error while trying to find class named '+apexClassName+' \n\n\n'+e.getMessage());
        }

        return output;
    }

    /**
     *  Exception class used for CLI based tasks.  This is created to prevent the need for another
     * class to be exposed to the subscriber org's default namespace as global.
     */
    global class CLIException extends Exception { }
}