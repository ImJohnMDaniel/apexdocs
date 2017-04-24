public class FileModel
	implements IFile
{
	private id codeInfoId;
	private type fileType;
	private string fileName;
	private id apexFileId;
	private boolean isModelCurrent = false;

	private FileModel()
	{

	}

	public FileModel(final id codeInfoId, final string name, final Type fileType, final id apexFileId)
	{
		this.codeInfoId = codeInfoId;
		this.fileName = name;
		this.fileType = fileType;
		this.apexFileId = apexFileId;
	}

	public id getId()
	{
		return codeInfoId;
	}

	public void setId(final id id)
	{
		this.codeInfoId = id;
	}

	public string getName()
	{
		return this.fileName;
	}

	public boolean getIsInterface()
	{
//		system.debug(this.fileType);
		return this.fileType.getName() == InterfaceModel.class.getName();
	}

    public id getApexFileId()
    {
        return this.apexFileId;
    }

    public void setApexFileId(final id apexFileId)
    {
        this.apexFileId = apexFileId;
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