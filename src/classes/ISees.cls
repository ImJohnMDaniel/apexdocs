/**
 *  ISees
 *  @author John M. Daniel
 *  @date 17 MARCH 2015
 *  @description This is the ISees Interface.  It sets the contract for
 *      the "see" annotation.
 *  @since 1.0
 *  @see ClassLinkModel
 */
public interface ISees
{
    /**
     * @param the ClassLinkModel representing the class or interface that should be reviewed.
     */
    void setSees( final list<ClassLinkModel> sees );

    /**
     * @return the list of ClassLinkModels representing the class or interface should be reviewed.
     */
    list<ClassLinkModel> getSees();

    void addSee(final string value);
}