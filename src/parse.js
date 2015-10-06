// Generated by LiveScript 1.4.0
(function(){
  var spawn, _, LET_RE, x$;
  spawn = require('child_process').spawn;
  _ = require('lodash');
  LET_RE = /^\s*([\s\S]+?)\s+=\s+([\s\S]+?)\s*$/;
  x$ = angular.module('app', ['RecursionHelper', 'ui.codemirror']);
  x$.controller("Ctrl", function($scope){
    $scope.code = "moo";
    $scope.editorOptions = {
      mode: "scheme",
      theme: "material"
    };
    $scope.parsed = {};
    $scope.output = {};
    $scope.data = [];
    $scope.codemirrorLoaded = function(editor){
      var words;
      words = [
        {
          text: "α",
          displayText: "\\alpha"
        }, {
          text: "β",
          displayText: "\\beta"
        }, {
          text: "γ",
          displayText: "\\gamma"
        }, {
          text: "δ",
          displayText: "\\delta"
        }, {
          text: "ε",
          displayText: "\\epsilon"
        }, {
          text: "ζ",
          displayText: "\\zeta"
        }, {
          text: "η",
          displayText: "\\eta"
        }, {
          text: "θ",
          displayText: "\\theta"
        }, {
          text: "ι",
          displayText: "\\iota"
        }, {
          text: "κ",
          displayText: "\\kappa"
        }, {
          text: "λ",
          displayText: "\\lambda"
        }, {
          text: "μ",
          displayText: "\\mu"
        }, {
          text: "ν",
          displayText: "\\nu"
        }, {
          text: "ξ",
          displayText: "\\xi"
        }, {
          text: "ο",
          displayText: "\\omicron"
        }, {
          text: "π",
          displayText: "\\pi"
        }, {
          text: "ρ",
          displayText: "\\rho"
        }, {
          text: "σ",
          displayText: "\\sigma"
        }, {
          text: "τ",
          displayText: "\\tau"
        }, {
          text: "υ",
          displayText: "\\upsilon"
        }, {
          text: "φ",
          displayText: "\\phi"
        }, {
          text: "χ",
          displayText: "\\chi"
        }, {
          text: "ψ",
          displayText: "\\psi"
        }, {
          text: "ω",
          displayText: "\\omega"
        }, {
          text: "↦",
          displayText: "|->"
        }, {
          text: "×",
          displayText: "\\times"
        }, {
          text: "∩",
          displayText: "\\cap"
        }
      ];
      CodeMirror.registerHelper("hint", "anyword", function(editor, options){
        var delimiters, whitespace, cur, curLine, start, end, curWord, filteredWords;
        delimiters = /[\\|]/;
        whitespace = /\s/;
        cur = editor.getCursor();
        curLine = editor.getLine(cur.line);
        start = cur.ch;
        end = start;
        while (end < curLine.length && !whitespace.test(curLine.charAt(end))) {
          end += 1;
        }
        while (start >= 1 && !delimiters.test(curLine.charAt(start)) && !whitespace.test(curLine.charAt(start - 1))) {
          start -= 1;
        }
        curWord = start !== end ? curLine.slice(start, end) : "";
        filteredWords = words.filter(function(w){
          return curWord.length > 0 && w.displayText.indexOf(curWord) === 0;
        });
        return {
          list: filteredWords,
          from: CodeMirror.Pos(cur.line, start),
          to: CodeMirror.Pos(cur.line, end)
        };
      });
      CodeMirror.commands.autocomplete = function(cm){
        return cm.showHint({
          hint: CodeMirror.hint.anyword,
          completeSingle: false
        });
      };
      return editor.on('keyup', function(editor, e){
        var keycode, valid;
        keycode = e.keyCode;
        valid = (keycode > 47 && keycode < 58) || (keycode === 32 || keycode === 13) || (keycode > 64 && keycode < 91) || (keycode > 95 && keycode < 112) || (keycode > 185 && keycode < 193) || (keycode > 218 && keycode < 223);
        if (valid) {
          CodeMirror.commands.autocomplete(editor);
        }
      });
    };
    $scope.splitTextToBlocks = function(input){
      var lines, blocks, i$, len$, i;
      lines = input.split("\n");
      blocks = [];
      for (i$ = 0, len$ = lines.length; i$ < len$; ++i$) {
        i = lines[i$];
        if (i.length > 0) {
          if (i[0] === "\t" && blocks.length > 0) {
            blocks[blocks.length - 1] = blocks[blocks.length - 1].concat(" " + i.slice(1));
          } else {
            blocks.push(i);
          }
        }
      }
      return blocks;
    };
    $scope.parseAndDisplay = function(){
      var blocks, jar, i$, ref$, len$, parsedBlock, err;
      $scope.parsed = [];
      $scope.output = [];
      $scope.data = [];
      blocks = $scope.splitTextToBlocks($scope.code);
      try {
        jar = spawn("java", ['-jar', 'lib/bell.jar', '-']);
        jar.stdout.on('data', function(data){
          console.log(data);
          $scope.output.push(JSON.parse(data));
          $scope.data.push({
            value: JSON.parse(data)
          });
          $scope.$apply();
        });
        jar.stderr.on('data', function(data){
          console.error('Java error: ' + data);
        });
        window.scope = [];
        $scope.parsed = _.chain(blocks).map(function(block){
          var p, parsed, results;
          p = new nearley.Parser(grammar.ParserRules, grammar.ParserStart);
          parsed = p.feed(block);
          results = _.filter(parsed.results, function(r){
            return r;
          });
          console.assert(results.length === 1, results);
          return results[0];
        }).filter(function(block){
          return block.root.kind !== 'set';
        }).value();
        jar.stdin.setEncoding('utf-8');
        for (i$ = 0, len$ = (ref$ = $scope.parsed).length; i$ < len$; ++i$) {
          parsedBlock = ref$[i$];
          jar.stdin.write(JSON.stringify(parsedBlock));
          jar.stdin.write("\n\n");
        }
        jar.stdin.end();
      } catch (e$) {
        err = e$;
        console.log(err);
        $scope.parsed = err;
      }
    };
  });
  x$.filter("collapse", function(){
    var lead;
    lead = function(it){
      return it.match(/^\s*/)[0].length;
    };
    return function(input, indent){
      return ("" + input).split(/\n/).filter(function(it){
        return lead(it) < indent;
      }).join("\n");
    };
  });
  x$.directive("display", function(RecursionHelper){
    return {
      restrict: 'E',
      scope: {
        o: '=o'
      },
      template: $('#display').html(),
      compile: function(element){
        return RecursionHelper.compile(element);
      }
    };
  });
  x$.directive("compute", function(){
    return {
      scope: {},
      transclude: 'element',
      link: function(scope, element, attrs, ctrl, $transclude){
        var expr, mo, lhs, rhs;
        expr = attrs['let'];
        mo = expr != null ? expr.match(LET_RE) : void 8;
        if (mo == null) {
          throw Error("invalid let '" + expr + "'");
        }
        lhs = mo[1];
        rhs = mo[2];
        return $transclude(function(clone, scope){
          scope.$watch(rhs, function(v){
            return scope[lhs] = v;
          }, true);
          return $(clone).insertAfter(element);
        });
      }
    };
  });
  x$.filter("isString", function(){
    return _.isString;
  });
  x$.filter("display", function(){
    return function(input){
      var last, text, x$, i$, ref$, len$, ref1$, ref2$, u, v, mark, x, y, cls;
      if (_.isString(input)) {
        return input;
      } else if (input.tape != null) {
        last = 0;
        text = input.tape.text;
        x$ = [];
        for (i$ = 0, len$ = (ref$ = input.tape.markup).length; i$ < len$; ++i$) {
          ref1$ = ref$[i$], ref2$ = ref1$[0], u = ref2$[0], v = ref2$[1], mark = ref1$[1];
          x = text.substring(last, u);
          y = text.substring(u, v);
          cls = ['mark'].concat(mark.type != null
            ? ['tip']
            : []);
          last = v;
          if (x.length) {
            x$.push([x]);
          }
          if (y.length) {
            x$.push([y, cls, mark.type]);
          }
        }
        x = text.substring(last);
        if (x.length) {
          x$.push([x]);
        }
        return x$;
      } else {
        return [JSON.stringify(input)];
      }
    };
  });
}).call(this);
