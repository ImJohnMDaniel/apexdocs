public class ReferenceClass0004 {

    public class QueryField implements Comparable{
        private List<Schema.SObjectField> fields;

        /**
         * The first field in the path to to field being queried
         **/
        public SObjectField getBaseField(){
            return fields[0];
        }

        public Integer compareTo(Object o){
            return null;
        }
    }

    public class QueryField3{ public void doSomething(){ } }
}