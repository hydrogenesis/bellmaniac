
package syntax


object AstSugar {

  type Term = Tree[Identifier]
  
  def I(a: Any) = new Identifier(a)
  def S(a: Any) = new Identifier(a, "set")
  def V(a: Any) = new Identifier(a, "variable")
  def T(a: Identifier, b: List[Tree[Identifier]]=List()) = new Tree(a, b)
  def TI(a: Any, b: List[Tree[Identifier]]=List()) = T(I(a), b)
  def TV(a: Any, b: List[Tree[Identifier]]=List()) = T(V(a), b)

  def symbols[T](t: Tree[T]) = (t.nodes map (_.root) toSet)
  
  implicit class TreeBuild[A](private val t: Tree[A]) extends AnyVal {
    def apply(subtrees: Tree[A]*) = new Tree(t.root, t.subtrees ++ subtrees)
    def apply(subtrees: List[Tree[A]]) = new Tree(t.root, t.subtrees ++ subtrees)
  }
  
  implicit class FormulaDisplay(private val term: Term) extends AnyVal {
    def toPretty: String = Formula.display(term)
  }
  
  // --------
  // DSL Part
  // --------
  
  val @: = TI("@")
  
  def ∀(vars: Term*)(body: Term): Term = ∀(vars.toList)(body)
  def ∀(vars: List[Term])(body: Term) = TI("∀")(vars)(body).foldRight

  implicit class DSL(private val term: Term) extends AnyVal {
    def ::(that: Term) = TI("::")(that, term)
    def -:(that: Term) = TI(":")(term, that)
    def :-(that: Term) = TI(":")(term, that)
    def |:(that: Term) = TI("|_")(that, term)
    def |!(that: Term) = TI("|!")(term, that)
    def /:(that: Term) = TI("/")(that, term)
    def ->(that: Term) = TI("->")(term, that)
    def ->:(that: Term) = TI("->")(that, term)
    def ↦(that: Term) = TI("↦")(term, that)
    def &(that: Term) = TI("&")(term, that)
    def |(that: Term) = TI("|")(term, that)
    def <->(that: Term) = TI("<->")(term, that)
    def unary_~ = TI("~")(term)
    def x(that: Term) = TI("x")(term, that)
    def ∩(that: Term) = TI("∩")(term, that)
    def +(that: Term) = @:(@:(TI("+"), term), that)
    def =:=(that: Term) = TI("=")(term, that)
    
    def :@(that: Term*) = @:(term)(that:_*).foldLeft
    
    def ~>[A](that: A) = if (term.isLeaf) term.root -> that
      else throw new Exception(s"mapping from non-leaf '$term'")
    
    def =~(root: Any, arity: Int) =
      term.root == root && term.subtrees.length == arity
      
    def ?(symbol: Any) =
      term.nodes find (_ =~ (symbol, 0)) getOrElse
      { throw new Exception(s"symbol '$symbol' not found in '$term'") }
      
    def :/(label: Any) =
      term.nodes find (t => t =~ (":", 2) && t.subtrees(0).root == label) getOrElse
      { throw new Exception(s"label '$label' not found in '$term'") }
    
    def :/(label: Any, subst: Term): Term =
      term.replaceDescendant((term :/ label).subtrees(1) → subst)
      
     def \(whatWith: (Term, Term)): Term =
       new syntax.transform.TreeSubstitution(List(whatWith))(term)
  }
  
  def &&(conjuncts: Term*): Term = &&(conjuncts.toList)
  def &&(conjuncts: List[Term]) = TI("&")(conjuncts).foldLeft
  
  class Uid {}
  def $_ = new Identifier("_", "placeholder", new Uid)
  def $v = new Identifier("?", "variable", new Uid)
      
}


object Formula {
  val INFIX = Map("->" -> 1, "<->" -> 1, "&" -> 1, "<" -> 1, "=" -> 1, "↦" -> 1, ":" -> 1, "::" -> 1,
      "/" -> 1, "|_" -> 1, "|!" -> 1, "∩" -> 1, "x" -> 1)
  val QUANTIFIERS = Set("forall", "∀", "exists", "∃")
  
  def display(term: AstSugar.Term): String =
    if (QUANTIFIERS contains term.root.toString)
      displayQuantifier(term.unfold)
    else
    (if (term.subtrees.length == 2) Formula.INFIX get term.root.toString else None)
    match {
      case Some(pri) => 
        s"${display(term.subtrees(0), pri)} ${term.root} ${display(term.subtrees(1), pri)}"
      case None => 
        if (term.isLeaf) term.root.toString
        else s"${term.root}(${term.subtrees map display mkString ", "})"
    }
  
  def display(term: AstSugar.Term, pri: Int): String = {
    if (term.subtrees.length != 2) term.toString
    else {
      val subpri = (INFIX get term.root.toString) getOrElse 0
      if (subpri < pri) display(term) else s"(${display(term)})"
    }
  }

  def displayQuantifier(term: AstSugar.Term) =
    s"${term.root}${term.subtrees dropRight 1 map display mkString " "} (${display(term.subtrees.last)})"
  
}


object Piping {
  
  implicit class Piper[X](private val x: X) extends AnyVal {
    def |>[Y](f: X => Y) = f(x)
  }
  
  implicit class PiedPiper[X,Y](private val f: X => Y) extends AnyVal {
    def |>:(x: X) = f(x)
  }
 
}