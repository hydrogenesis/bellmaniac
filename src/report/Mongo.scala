package report

import collection.JavaConversions._
import java.io.ByteArrayOutputStream
import com.mongodb.MongoClient
import com.mongodb.DBCollection
import com.mongodb.BasicDBObject
import com.mongodb.MongoClientOptions
import com.mongodb.MongoTimeoutException
import com.mongodb.DBObject
import com.mongodb.BasicDBList
import report.data.TapeString
import syntax.Tree
import com.mongodb.DB



trait AppendLog {
  def +=(text: String)
  def +=(any: Any) { this += any.toString }
  
  def <<(op: => Unit) {
    val ss = new ByteArrayOutputStream
    Console.withOut(ss)(op)
    this += new String(ss.toByteArray(), "utf-8")
  }
}

class DevNull extends AppendLog {
  def +=(text: String) {}
}

class NotebookLog(cells: DBCollection) extends AppendLog {
  
  var sz = cells.getCount
  
  def clear {
    cells.remove(new BasicDBObject)
    sz = 0
  }
  
  def addCell(cell: BasicDBObject) {
    cells.insert(cell.append("index", sz))
    sz += 1
  }
  
  def +=(text: String) {
    addCell(new BasicDBObject("code", text))
  }
  
  def +=(json: DBObject) {
    addCell(new BasicDBObject("code", json))
  }
  
  override def +=(any: Any) = any match {
    case json: DBObject => this += json
    case as: DisplayAsJson => this += as.displayAsJson
    case _ => super.+=(any)
  }
  
}


object NotebookLog {
  
  val mongo: MongoClient = null /*try {
    new MongoClient("localhost:5001", MongoClientOptions.builder.connectTimeout(100).build )
  } catch { case _: MongoTimeoutException => null }*/
  
  val out = if (mongo == null) new DevNull
    else {
      val log = new NotebookLog(mongo.getDB("meteor").getCollection("cells"))
      log.clear
      log
    }
}


trait DisplayAsJson {
  def displayAsJson: DBObject
}

object DisplayAsJson {
  def toJson(a: Any) = a match {
    case as: DisplayAsJson => as.displayAsJson
    case _ => a.toString
  }
}


class ObjectList[A](val elements: List[A]) extends DisplayAsJson {
  def displayAsJson = new BasicDBObject("list", ObjectList.toJson(elements))
}

object ObjectList {
  def mkList(list: List[Object]) = {
    val l = new BasicDBList
    l.addAll(list)
    l
  }
  def toJson[A](list: List[A]) = mkList(list map DisplayAsJson.toJson)
}

class ObjectVBox[A](val elements: List[A]) extends DisplayAsJson {
  def displayAsJson = new BasicDBObject("vbox", ObjectList.toJson(elements))
}

class ObjectTree[A](val tree: Tree[A]) extends DisplayAsJson {
  def displayAsJson = new BasicDBObject("tree", ObjectTree.toJson(tree))
}

object ObjectTree {
  def toJson[A](tree: Tree[A]): DBObject = 
    new BasicDBObject("root", DisplayAsJson.toJson(tree.root))
              .append("subtrees", ObjectList.mkList(tree.subtrees map toJson))
}

trait BulletDecorator extends DisplayAsJson {
  val ● : String = "•"
  abstract override def displayAsJson = (super.displayAsJson match {
    case bobj: BasicDBObject => bobj
    case obj => new BasicDBObject("data", obj)
  }).append("bullet", ●)
}

