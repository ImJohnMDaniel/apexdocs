/**
 *  This interface sets the contract for
 *      the "link" annotation found in description comments
 *  @author John M. Daniel
 *  @date 17 MARCH 2015
 *  @since 1.0
 *  @see ClassLinkModel
 */
public interface IDescriptionLinks
{
    /**
     * @param the ClassLinkModel representing the class or interface that should be reviewed.
     */
    void setDescriptionLinks( final list<ClassLinkModel> descriptionLinks );

    /**
     * @return the list of ClassLinkModels representing the class or interface should be reviewed.
     */
    list<ClassLinkModel> getDescriptionLinks();

    void addDescriptionLink(final string value);

}