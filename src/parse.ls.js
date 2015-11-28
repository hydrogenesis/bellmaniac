// Generated by LiveScript 1.4.0
(function(){
  var spawn, assert, _, root, stripComments, readResponseBlocks, wrapWith, slice$ = [].slice;
  spawn = require('child_process').spawn;
  assert = require('assert');
  _ = require('lodash');
  root = typeof exports != 'undefined' && exports !== null ? exports : this;
  stripComments = function(input){
    return input.replace(/\s*\/\/.*$|\/\*[\s\S]*?\*\//mg, '');
  };
  root.splitTextToBlocks = function(input){
    var blocks, countLines;
    blocks = input.split(/(\n+)(?!\s)/).map(function(it){
      return {
        text: it
      };
    });
    countLines = function(text){
      return (text.match(/\n/g) || []).length;
    };
    _.reduce(blocks, function(x, y){
      y.line = x;
      return x + countLines(y.text);
    }, 1);
    return blocks.filter(function(it){
      return /\S/.exec(it.text);
    });
  };
  readResponseBlocks = function(output, parsedInputs){
    var i$, ref$, len$, blockIdx, block, outputBlock, err, x$, ref1$, ref2$, results$ = [];
    for (i$ = 0, len$ = (ref$ = output.split(/\n\n+(?=\S)/)).length; i$ < len$; ++i$) {
      blockIdx = i$;
      block = ref$[i$];
      try {
        outputBlock = JSON.parse(block);
        if (outputBlock.error) {
          throw outputBlock;
        }
        results$.push({
          value: outputBlock
        });
      } catch (e$) {
        err = e$;
        x$ = parsedInputs[blockIdx];
        err.line = (ref1$ = (ref2$ = x$.check) != null
          ? ref2$
          : x$.tactic) != null ? ref1$.line : void 8;
        throw err;
      }
    }
    return results$;
  };
  wrapWith = function(term, rootLiteral, kind){
    kind == null && (kind = '?');
    if (term.root.literal !== rootLiteral) {
      return tree(identifier(rootLiteral, kind), [term]);
    } else {
      return term;
    }
  };
  root.bellmaniaParse = function(input, success, error, name){
    var blocks, output, launch, flags, jar, fromStream, mode, toStream, stream, err;
    name == null && (name = 'synopsis');
    blocks = splitTextToBlocks(stripComments(input.text));
    try {
      output = {
        fromNearley: [],
        fromJar: []
      };
      launch = root.devmode
        ? ['../Bellmaniac/bell', 'ui.CLI']
        : ['java', '-jar', 'lib/bell.jar'];
      flags = (input.dryRun
        ? ['--dry-run']
        : []).concat(['-']);
      jar = spawn(launch[0], slice$.call(launch, 1).concat(flags));
      fromStream = function(stream, callback){
        var buffer;
        stream.setEncoding('utf-8');
        buffer = [];
        stream.on('data', function(data){
          buffer.push(data);
        });
        return stream.on('end', function(){
          callback(buffer.join(""));
        });
      };
      fromStream(jar.stdout, function(out){
        var err;
        try {
          output.fromJar = readResponseBlocks(out, output.fromNearley);
          success(output);
        } catch (e$) {
          err = e$;
          error(err, output);
        }
      });
      fromStream(jar.stderr, function(err){
        if (err !== "") {
          error({
            message: err
          }, output);
        }
      });
      root.scope = [];
      mode = "check";
      if (input.scope) {
        output.scope = _.uniq(window.scope.concat(input.scope), function(s){
          var ref$;
          return (ref$ = s.literal) != null
            ? ref$
            : s[0].literal;
        });
      } else {
        output.scope = window.scope;
      }
      output.fromNearley = _.chain(blocks).map(function(block){
        var p, parsed, results, x$, ref$, err;
        p = new nearley.Parser(grammar.ParserRules, grammar.ParserStart);
        try {
          parsed = p.feed(block.text);
          results = _.compact(parsed.results);
          if (results.length === 0) {
            throw {
              message: "No possible parse of input found."
            };
          }
          assert(results.length === 1, JSON.stringify(results) + " is not a unique parse.");
          x$ = (ref$ = results[0], ref$.mode = mode, ref$.line = block.line, ref$);
          if (x$.setMode != null) {
            mode = x$.setMode;
          }
          return x$;
        } catch (e$) {
          err = e$;
          err.line = block.line;
          throw err;
        }
      }).filter(function(block){
        return block.kind !== 'set' && !(block.setMode != null);
      }).map(function(block){
        var ref$;
        return ref$ = {}, ref$[block.mode] = block, ref$.scope = output.scope, ref$;
      }).value();
      toStream = function(stream){
        var i$, ref$, len$, parsedBlock, term, tacticBlock;
        if (input.isTactic) {
          for (i$ = 0, len$ = (ref$ = output.fromNearley).length; i$ < len$; ++i$) {
            parsedBlock = ref$[i$];
            term = wrapWith(input.termJson, 'program');
            tacticBlock = {
              tactic: parsedBlock.check,
              term: term,
              scope: parsedBlock.scope
            };
            stream.write(JSON.stringify(tacticBlock));
            stream.write("\n\n");
          }
        } else {
          for (i$ = 0, len$ = (ref$ = output.fromNearley).length; i$ < len$; ++i$) {
            parsedBlock = ref$[i$];
            stream.write(JSON.stringify(parsedBlock));
            stream.write("\n\n");
          }
        }
        return stream.end();
      };
      fs.writeFileSync("/tmp/" + name + ".txt", input.text);
      stream = fs.createWriteStream("/tmp/" + name + ".json");
      stream.once('open', function(){
        return toStream(stream);
      });
      jar.stdin.setEncoding('utf-8');
      return toStream(jar.stdin);
    } catch (e$) {
      err = e$;
      return error(err);
    }
  };
  if (typeof localStorage != 'undefined' && localStorage !== null) {
    root.devmode = JSON.parse(localStorage['bell.devmode']);
  }
}).call(this);
