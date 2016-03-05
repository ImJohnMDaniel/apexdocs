public class ReferenceClass0010
{
    private ReferenceClass0010()
    {

    }

    private class InnerPrivateClass
    {
        // Does this method show up?  It should not because
        // the method is inside the private inner class.
        public void InnerPublicMethod()
        {

        }
    }
}