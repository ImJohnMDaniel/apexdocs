public class FileModel
	implements IFile
{
	private id codeInfoId;
	private type fileType;
	private string fileName;
	private id apexFileId;

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
}