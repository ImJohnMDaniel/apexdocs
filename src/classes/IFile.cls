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

    /**
     *  Method is used to determine if the model information currently stored is up to date or
     *  has there been an update to the Apex Class since the last documentation event.
     *  @return boolean - true if the Apex Class and documented model information are in sync.
     */
    boolean getIsModelCurrent();

    /**
     *  convenience method to return same information as the getIsModelCurrent() method.
     */
    boolean isModelCurrent();

    /**
     *  Setter method for the isModelCurrent value
     */
    void setIsModelCurrent(final boolean isModelCurrent);

    /**
     *  @return the Id for the Attachment file that contains the JSON representation of the class
     */
    id getCodeInfoAttachmentId();

    /**
     *  Setter method for the Id of the Attachment file that contains the JSON representation of the class
     */
    void setCodeInfoAttachmentId(final id codeInfoAttachmentId);


}