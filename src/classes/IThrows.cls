public interface IThrows
{
    /**
     * @param the ClassLinkModel representing the class or interface that should be reviewed.
     */
    void setThrows( final list<ClassLinkModel> sees );

    /**
     * @return the list of ClassLinkModels representing the class or interface should be reviewed.
     */
    list<ClassLinkModel> getThrows();
}