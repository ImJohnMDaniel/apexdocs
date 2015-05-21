public interface IApexFileInfo
{
    /**
     *  @return the Createddate of the associated ApexClass CreatedDate field
     */
    DateTime getApexFileCreatedDate();

	/**
     *  This is the setter for the associated ApexClass CreatedDate field.
     * @param apexFileCreatedDate
     */
    void setApexFileCreatedDate(final DateTime apexFileCreatedDate);

    /**
     *  @return the CreatedById of the associated ApexClass record
     */
    id getApexFileCreatedById();

	/**
     *  This is the setter for the associated ApexClass CreatedById field.
     * @param apexFileCreatedById
     */
    void setApexFileCreatedById(final id apexFileCreatedById);

    /**
     *  @return the CreatedBy.name of the associated ApexClass record
     */
    string getApexFileCreatedByName();

	/**
     *  This is the setter for the associated ApexClass CreatedBy.Name field.
     * @param apexFileCreatedByName
     */
    void setApexFileCreatedByName(final string apexFileCreatedByName);

	/**
     *  @return the LastModifieddate of the associated ApexClass record
     */
    DateTime getApexFileLastModifiedDate();

	/**
     * This is the setter for the associated ApexClass LastModifiedDate field.
	 * @return the LastModifiedDate of the associated ApexClass record
     */
    void setApexFileLastModifiedDate(final DateTime apexFileLastModifiedDate);

    /**
     *  @return the LastModifiedById of the associated ApexClass record
     */
    id getApexFileLastModifiedById();

	/**
     *  This is the setter for the associated ApexClass LastModifiedById field.
     * @param apexFileLastModifiedById
     */
    void setApexFileLastModifiedById(final id apexFileLastModifiedById);

    /**
     *  @return the LastModifiedBy.name of the associated ApexClass record
     */
    string getApexFileLastModifiedByName();

	/**
     *  This is the setter for the associated ApexClass LastModifiedBy.Name field.
     * @param apexFileLastModifiedByName
     */
    void setApexFileLastModifiedByName(final string apexFileLastModifiedByName);

}