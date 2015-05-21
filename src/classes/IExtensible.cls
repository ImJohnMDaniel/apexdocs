/**
 *  IExtensible
 *  @author John M. Daniel
 *  @date 17 MARCH 2015
 *  @description This is the IExtensible.
 *  @since 1.0
 *  @see ClassLinkModel
 */
public interface IExtensible
{
    /**
     * @param the ClassLinkModel representing the class or interface that the parent file is extending.
     */
    void setExtends( final ClassLinkModel params );

    /**
     * @return the ClassLinkModel representing the class or interface that the parent file is extending.
     */
    ClassLinkModel getExtends();
}