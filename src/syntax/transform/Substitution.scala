
package syntax.transform

import syntax.{Tree,Identifier}



class GenTreeSubstitution[A](substitutions: List[(Tree[A], (Tree[A] => Tree[A]))]) {
  
  def apply(t: Tree[A], eq: (Tree[A], Tree[A]) => Boolean=(_ == _)): Tree[A] =
    substitutions find (s => eq(t, s._1)) match {
    case Some((x,y)) => preserve(t, y(x))
    case _ => preserve(t, new Tree(t.root, t.subtrees map (this(_, eq))))
  }
  
  def preserve(old: Tree[A], new_ : Tree[A]) = new_
}

class TreeSubstitution[A](substitutions: List[(Tree[A], Tree[A])])
  extends GenTreeSubstitution[A](substitutions.map (kv => (kv._1, (x:Tree[A]) => kv._2)))