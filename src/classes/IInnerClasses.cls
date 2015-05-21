/**
 *  IInnerClasses
 *  @author John M. Daniel
 *  @date 15 MARCH 2015
 *  @description This is the IInnerClasses.  It sets the contract for
 *      the presence of inner classes
 *  @since 1.0
 */
public interface IInnerClasses
{
    /**
     * @param list of ClassModels.  One for each inner class.
     */
    void setInnerClasses( final list<ClassModel> innerClasses );

    /**
     * @return a list of ClassModels
     */
    list<ClassModel> getInnerClasses();
}