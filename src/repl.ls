_ = require \lodash
LET_RE = /^\s*([\s\S]+?)\s+=\s+([\s\S]+?)\s*$/

angular.module 'app', [\RecursionHelper, \ui.codemirror, \ui.select]
  ..controller "Ctrl" ($scope, $timeout) !->

    $scope.cmOptions = cmOptions()
    $scope.wrapper = (parent) ->
        submitCallback = (cm) ->

            calc = cm.parent
            calc.output = null
            calc.error = null

            success = (output) ->
                $timeout(->
                    calc.output = output.fromJar
                    thisIdx = 1 + _.findIndex($scope.history, (h) ->
                        h.id == calc.id
                    )

                    if (thisIdx == ($scope.history.length))
                        $scope.history.push({id: thisIdx + 1, input: "", output: null, error: null})

                    $scope.mostRecentId = thisIdx
                )

            error = (err) ->
                $timeout(->
                    calc.error = err.message
                )

            bellmaniaParse(calc.input, success, error)
            cm.getInputField().blur()
            $scope.$apply()

        loadCallback = (cm) ->
            cm.parent = parent

        initEditor(submitCallback, loadCallback)

    $scope.history = [
        {id: 1, input: "a b", output: null, error: null}
    ]
    $scope.mostRecentId = 1
    $scope.isInvalid = (h) ->
        return ($scope.mostRecentId < h.id && h.output != null)
    $scope.output = {}
    $scope.data = []
  ..filter "collapse" ->
    lead = -> it.match /^\s*/ .0.length
    (input, indent) ->
      (""+input).split /\n/ \
        .filter (-> lead(it) < indent) \
        .join "\n"
  ..directive "display" (RecursionHelper) ->
    restrict: 'E'
    scope:
      o: '=o'
    template: $ '#display' .html!
    compile: (element) ->
      RecursionHelper.compile(element)
  ..directive "compute" ->
    scope: {}
    transclude: 'element'
    link: (scope, element, attrs,
           ctrl, $transclude) ->
      expr = attrs.let
      mo = expr?.match LET_RE
      if !mo?
        throw Error("invalid let '#expr'")
      lhs = mo[1]
      rhs = mo[2]
      $transclude (clone, scope) ->
        scope.$watch rhs, (v) ->
          scope[lhs] = v
        , true
        $(clone).insertAfter element

  ..filter "isString" -> _.isString

  ..filter "display" ->
    (input) ->
      if _.isString input
        input
      else if input.tape?
        last = 0
        text = input.tape.text
        []
          for [[u,v], mark] in input.tape.markup
            x = text.substring(last,u)
            y = text.substring(u,v)
            cls = ['mark'] ++ (if mark.type? then ['tip'] else [])
            last = v
            if x.length then ..push [x]
            if y.length then ..push [y,cls,mark.type]
          x = text.substring(last)
          if x.length then ..push [x]
        #JSON.stringify input.tape.markup
      else
        [JSON.stringify input]
