/**
 *  InterfaceModel
 *  @author John M. Daniel
 *  @date 4 MARCH 2015
 *  @Description This is the InterfaceModel.  It holds the references to
 *      an interface.
 *
 */
public class InterfaceModel extends ApexConstructBaseModel
    implements IApexModel, IFile, IMethods, IAuthorable
            , IExtensible, IApexFileInfo
{
    public override type getClassType()
    {
        return InterfaceModel.class;
    }

    private id apexFileId;
    private id codeInfoId;
    private id codeInfoAttachmentId;

    private string apexFileLastModifiedByName;
    private id apexFileLastModifiedById;
    private DateTime apexFileLastModifiedDate;
    private string apexFileCreatedByName;
    private id apexFileCreatedById;
    private DateTime apexFileCreatedDate;
    private boolean isModelCurrent = false;

    private ClassLinkModel extendsInterface = null;
    private list<MethodModel> methods = new list<MethodModel>();
    private list<string> authors = new list<string>();

    public id getApexFileId()
    {
        return this.apexFileId;
    }

    public list<string> getAuthors()
    {
        return this.authors;
    }

    public id getCodeInfoAttachmentId()
    {
        return this.codeInfoAttachmentId;
    }

    public ClassLinkModel getExtends()
    {
        return this.extendsInterface;
    }

    public id getId()
    {
        return this.codeInfoId;
    }

    public boolean getIsInterface()
    {
        return true;
    }

    public string getName()
    {
        string nameLine = getNameLine();

        if (nameLine != null) nameLine = nameLine.trim();
        //system.debug('@@ File Name = ' + nameLine);

        if(nameLine != null && nameLine.trim().length() > 0 )
        {
        	string interfaceKeywordToFind = ' interface ';
            //system.debug('## File Name = ' + nameLine.trim().lastIndexOf(' '));
            integer fFound = nameLine.toLowerCase().indexOf(interfaceKeywordToFind);
            integer lFound = nameLine.toLowerCase().indexOf(' ', fFound + interfaceKeywordToFind.length());

            if (lFound == -1)
                return nameLine.substring(fFound + interfaceKeywordToFind.length());

            try
            {
                String name = nameLine.substring(fFound + interfaceKeywordToFind.length(), lFound);
                return name;
            }
            catch (Exception ex)
            {
                return nameLine.substring(nameLine.lastIndexOf(' ') + 1);
            }
        }
        else
        {
            return '';
        }
    }

    public list<MethodModel> getMethods()
    {
        return this.methods;
    }

    public void set(final string tag, final string value)
    {
        if (tag == 'description')
        {
            //this.setDescription( ( this.getDescription() == null ? '' : this.getDescription() + ' ' ) + value );
            this.addDesciptionLine( value );
        }
        else if (tag == 'author')
        {
            this.getAuthors().add(value);
        }
        else if (tag == 'see')
        {
            this.addSee(value);
        }
        else if (tag == 'since')
        {
            this.setSince(value);
        }
        else if (tag == 'date')
        {
            this.setDate(value);
        }
        else if (tag == 'deprecated')
        {
            this.setDeprecated(true);
        }
    }

    public void setApexFileId(final id id)
    {
        this.apexFileId = id;
    }

    public void setAuthor(final string author)
    {
        this.authors.add(author);
    }

    public void setAuthor(final list<string> authors)
    {
        this.authors = authors;
    }

    public void setCodeInfoAttachmentId(final id codeInfoAttachmentId)
    {
        this.codeInfoAttachmentId = codeInfoAttachmentId;
    }

    public void setExtends(final ClassLinkModel extendsInterface)
    {
        this.extendsInterface = extendsInterface;
    }

    public void setId(final id codeInfoId)
    {
        this.codeInfoId = codeInfoId;
    }

    public void setMethods(final list<MethodModel> methods)
    {
        this.methods = methods;
    }

    /**
     *  @return the Createddate of the associated ApexClass CreatedDate field
     */
    public DateTime getApexFileCreatedDate()
    {
        return this.apexFileCreatedDate;
    }

	/**
     *  This is the setter for the associated ApexClass CreatedDate field.
     * @param apexFileCreatedDate
     */
    public void setApexFileCreatedDate(final DateTime apexFileCreatedDate)
    {
        this.apexFileCreatedDate = apexFileCreatedDate;
    }

    /**
     *  @return the CreatedById of the associated ApexClass record
     */
    public id getApexFileCreatedById()
    {
        return this.apexFileCreatedById;
    }

	/**
     *  This is the setter for the associated ApexClass CreatedById field.
     * @param apexFileCreatedById
     */
    public void setApexFileCreatedById(final id apexFileCreatedById)
    {
        this.apexFileCreatedById = apexFileCreatedById;
    }

    /**
     *  @return the CreatedBy.name of the associated ApexClass record
     */
    public string getApexFileCreatedByName()
    {
        return this.apexFileCreatedByName;
    }

	/**
     *  This is the setter for the associated ApexClass CreatedBy.Name field.
     * @param apexFileCreatedByName
     */
    public void setApexFileCreatedByName(final string apexFileCreatedByName)
    {
        this.apexFileCreatedByName = apexFileCreatedByName;
    }

	/**
     *  @return the LastModifieddate of the associated ApexClass record
     */
    public DateTime getApexFileLastModifiedDate()
    {
        return this.apexFileLastModifiedDate;
    }

	/**
     * This is the setter for the associated ApexClass LastModifiedDate field.
	 * @return the LastModifiedDate of the associated ApexClass record
     */
    public void setApexFileLastModifiedDate(final DateTime apexFileLastModifiedDate)
    {
        this.apexFileLastModifiedDate = apexFileLastModifiedDate;
    }

    /**
     *  @return the LastModifiedById of the associated ApexClass record
     */
    public id getApexFileLastModifiedById()
    {
        return this.apexFileLastModifiedById;
    }

	/**
     *  This is the setter for the associated ApexClass LastModifiedById field.
     * @param apexFileLastModifiedById
     */
    public void setApexFileLastModifiedById(final id apexFileLastModifiedById)
    {
        this.apexFileLastModifiedById = apexFileLastModifiedById;
    }

    /**
     *  @return the LastModifiedBy.name of the associated ApexClass record
     */
    public string getApexFileLastModifiedByName()
    {
        return this.apexFileLastModifiedByName;
    }

	/**
     *  This is the setter for the associated ApexClass LastModifiedBy.Name field.
     * @param apexFileLastModifiedByName
     */
    public void setApexFileLastModifiedByName(final string apexFileLastModifiedByName)
    {
        this.apexFileLastModifiedByName = apexFileLastModifiedByName;
    }

    /**
     *  Method is used to determine if the model information currently stored is up to date or
     *  has there been an update to the Apex Class since the last documentation event.
     *  @return boolean - true if the Apex Class and documented model information are in sync.
     */
    public boolean getIsModelCurrent()
    {
        return this.isModelCurrent;
    }

    /**
     *  convenience method to return same information as the getIsModelCurrent() method.
     */
    public boolean isModelCurrent()
    {
        return this.isModelCurrent;
    }

    /**
     *  Setter method for the isModelCurrent value
     */
    public void setIsModelCurrent(final boolean isModelCurrent)
    {
        this.isModelCurrent = isModelCurrent;
    }

}