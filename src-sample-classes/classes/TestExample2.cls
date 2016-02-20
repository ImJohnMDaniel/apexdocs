public class TestExample2 {

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
}