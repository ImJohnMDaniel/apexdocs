public interface IFile
{
	/**
	 *	This is the setter for the file CodeInfo__c record.  The is not the ApexClass id.
	 *	@param fileId
	 */
    void setId(final id fileId);

    /**
     * This is the getter for the file CodeInfo__c record.  The is not the ApexClass id.
     * @return file id
     */
    id getId();

    /**
     *	@return the file name
     */
    string getName();

    /**
     *  @return the id for the ApexClass
     */
    id getApexFileId();

    /**
     *  This is the setter for the associated ApexClass record.
     * @param apexFileId
     */
    void setApexFileId(final id apexFileId);

    /**
     *  A convenience function to determine if the concreate object is an interface or not.
     *  @return boolean - true if the object is an Apex Interface.  false if the object is an Apex Class
     */
    boolean getIsInterface();

}