/**
 *  ScratchBatchExample
 */
public with sharing class ScratchBatchExample
    implements Database.Batchable<CodeDocumentScopeChunk>//, Database.Stateful
{
    private list<CodeDocumentScopeChunk> chunksToDocument = new list<CodeDocumentScopeChunk>();

    private ScratchBatchExample() { }

    public ScratchBatchExample( list<CodeDocumentScopeChunk> chunksToDocument )
    {
        system.debug( chunksToDocument.size() );
        system.debug( chunksToDocument );

        this.chunksToDocument = chunksToDocument;
    }

    public Iterable<CodeDocumentScopeChunk> start(Database.BatchableContext BC)
    {
        return this.chunksToDocument;
    }

    public void execute(Database.BatchableContext BC, List<CodeDocumentScopeChunk> scope)
    {
        system.debug( scope );
    }

    public void finish(Database.BatchableContext BC)
    {

    }

    public static void documentApexFilesInBatchMode( list<CodeDocumentScopeChunk> chunksToDocument )
    {
        // apexClassIds
        Database.executeBatch(new ScratchBatchExample( chunksToDocument ), 1);
    }

    public class CodeUnitToDocument
    {
        private id apexClassId = null;
        private integer startLine = null;
        private integer endLine = null;
        private integer totalLinesToDocument = 0;

        private CodeUnitToDocument() { }

        public CodeUnitToDocument( Id apexClassId )
        {
            this.apexClassId = apexClassId;
        }

        public id getApexClassId()
        {
            return this.apexClassId;
        }

        public boolean isDocumentingWholeClass()
        {
            return this.startLine == null
                && this.endLine == null;
        }

        public boolean isDocumentingRemainderOfClass()
        {
            return this.startLine != null
                && this.endLine == null;
        }

        public integer getStartLine()
        {
            return this.startLine;
        }

        public integer getEndLine()
        {
            return this.endLine;
        }

        public integer getTotalLinesToDocument()
        {
            return this.totalLinesToDocument;
        }

        public CodeUnitToDocument setStartLine(integer startLine)
        {
            this.startLine = startLine;

            return this;
        }

        public CodeUnitToDocument setEndLine(integer endLine)
        {
            this.endLine = endLine;

            return this;
        }

        public CodeUnitToDocument setTotalLinesToDocument(integer lineCount)
        {
            this.totalLinesToDocument = lineCount;

            return this;
        }
    }

    public class CodeDocumentScopeChunk
        implements Iterable<Object>
    {
        private list<CodeUnitToDocument> codeUnitsToDocumentList = new list<CodeUnitToDocument>();

        public CodeDocumentScopeChunk() { }

        public CodeDocumentScopeChunk addToScope( CodeUnitToDocument codeUnit )
        {
            this.codeUnitsToDocumentList.add( codeUnit );

            return this;
        }

        public list<CodeUnitToDocument> getCodeUnitsToDocumentList()
        {
            return this.codeUnitsToDocumentList;
        }

        public Iterator<Object> iterator()
        {
            return (Iterator<Object>) this.codeUnitsToDocumentList;
        }

        public integer getTotalNumberOfCodeLinesToDocument()
        {
            integer output = 0;

            for (CodeUnitToDocument codeUnit : this.codeUnitsToDocumentList )
            {
                output += codeUnit.getTotalLinesToDocument();
            }

            return output;
        }
    }
}