function result = dbDom2XML(dom)

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.TransformerFactory;

import java.io.StringWriter;

factory = DocumentBuilderFactory.newInstance();
builder = factory.newDocumentBuilder();

src = DOMSource(dom);
writer = StringWriter();
output = StreamResult(writer);

tfactory = TransformerFactory.newInstance();
transformer = tfactory.newTransformer();
transformer.transform(src, output);

result = char(writer.toString());
1;



