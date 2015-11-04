spawn = require \child_process .spawn
assert = require \assert
_ = require \lodash

root = exports ? this

stripComments = (input) ->
    input.replace //  \s* \/\/ .*$  |  \/\* [\s\S]*? \*\/  //mg, ''

splitTextToBlocks = (input) ->
    blocks = input.split /(\n+)(?!\s)/ .map ->
      text: it
    countLines = (text) -> (text.match(/\n/g)||[]).length
    _.reduce blocks, ((x,y) -> y.line = x ; x + countLines(y.text)), 1
    blocks .filter (.text == /\S/)

# input is of form
#     {isTactic: bool,
#      text: string from codemirror
#      termJson:? previous json if isTactic is true
#      scope:? previous scope if isTactic is true
#     }
root.bellmaniaParse = (input, success, error) ->
    console.log(input)

    blocks = splitTextToBlocks(stripComments(input.text))

    try
        buffer = []

        output =
            fromNearley: []
            fromJar: []

        # spawn jar and initialize jar behavior
        jar = spawn "java", <[-jar lib/bell.jar -]>
        jar.stdout.setEncoding('utf-8')
        jar.stdout.on \data, (data) !->
            buffer.push(data)

        jar.stdout.on \end, !->
            try
                for block in buffer.join("").split(/\n\n+(?=\S)/)
                    outputBlock = JSON.parse(block)
                    if (outputBlock.error)
                        throw outputBlock
                    output.fromJar.push({value: outputBlock})
                success(output)
            catch err
                console.log err
                error(err)

        jar.stderr.on \data, (data) !->
            error(data)

        # reset global list of sets to empty
        root.scope = []

        output.fromNearley = _.chain(blocks)
        .map((block) ->
            # parse block with nearley, filter only non-false results, assert parse unambiguous
            p = new nearley.Parser grammar.ParserRules, grammar.ParserStart
            try
              parsed = p.feed block.text
              results = _.compact parsed.results
              if results.length == 0 then throw {msg: "no possible parse of input found"}
              assert results.length == 1, JSON.stringify(results) + " is not a unique parse."
              results[0]
            catch err
              throw {line: block.line, err: err}
        ).filter((block) ->
            # only take the expressions that aren't set declarations
            # nearley has already pushed set declarations to root.scope
            block.kind != \set
        ).map((block) ->
            # wrap each expression in another layer that includes scope
            check: block
            scope: window.scope
        ).value!

        toStream = (stream) ->
            if input.isTactic
                for parsedBlock in output.fromNearley
                    tacticBlock = {
                        tactic: parsedBlock.check,
                        term: tree(identifier(\program, \variable), [input.termJson.check])
                    }
                    console.log("sending2");
                    console.log(JSON.stringify(tacticBlock, null, 2));
                    stream.write <| JSON.stringify(tacticBlock)
                    # stream.write '{ "tactic" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "@" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "@" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "Slice" , "kind" : "variable"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "@" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "find" , "kind" : "variable"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "↦" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "θ" , "kind" : "variable"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "?" , "kind" : "variable"} , "subtrees" : [ ]}]}]}]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "@" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "?" , "kind" : "type variable"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "@" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "@" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "cons" , "kind" : "variable"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "×" , "kind" : "operator"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J₀" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J₀" , "kind" : "set"} , "subtrees" : [ ]}]}]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "@" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "@" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "cons" , "kind" : "variable"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "×" , "kind" : "operator"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J₀" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J₁" , "kind" : "set"} , "subtrees" : [ ]}]}]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "@" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "@" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "cons" , "kind" : "variable"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "×" , "kind" : "operator"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J₁" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J₁" , "kind" : "set"} , "subtrees" : [ ]}]}]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "nil" , "kind" : "variable"} , "subtrees" : [ ]}]}]}]}]}]} , "term" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "program" , "kind" : "variable"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "↦" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "ψ" , "kind" : "variable"} , "subtrees" : [ ] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]}]}} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "fix" , "kind" : "operator"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "↦" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "θ" , "kind" : "variable"} , "subtrees" : [ ] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "∩" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "×" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]}]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "<" , "kind" : "type variable"} , "subtrees" : [ ]}]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]}} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "↦" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "i" , "kind" : "variable"} , "subtrees" : [ ] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]}} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "↦" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "j" , "kind" : "variable"} , "subtrees" : [ ] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]}} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "@" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "min" , "kind" : "variable"} , "subtrees" : [ ] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "N" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]}} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "@" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "@" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "cons" , "kind" : "variable"} , "subtrees" : [ ] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "N" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "N" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]}]}]}} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "@" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "@" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "ψ" , "kind" : "variable"} , "subtrees" : [ ] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]}]}} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "i" , "kind" : "variable"} , "subtrees" : [ ] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]}}] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]}} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "j" , "kind" : "variable"} , "subtrees" : [ ] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]}}] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}}] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "N" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "N" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]}]}} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "@" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "@" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "cons" , "kind" : "variable"} , "subtrees" : [ ] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "N" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "N" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]}]}]}} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "@" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "min" , "kind" : "variable"} , "subtrees" : [ ] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]}} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "↦" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "k" , "kind" : "variable"} , "subtrees" : [ ] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]}} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "@" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "@" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "+" , "kind" : "operator"} , "subtrees" : [ ] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]}]}} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "@" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "@" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "θ" , "kind" : "variable"} , "subtrees" : [ ] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "∩" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "×" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]}]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "<" , "kind" : "type variable"} , "subtrees" : [ ]}]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]}} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "i" , "kind" : "variable"} , "subtrees" : [ ] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]}}] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]}} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "k" , "kind" : "variable"} , "subtrees" : [ ] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]}}] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}}] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]}} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "@" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "@" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "θ" , "kind" : "variable"} , "subtrees" : [ ] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "∩" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "×" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]}]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "<" , "kind" : "type variable"} , "subtrees" : [ ]}]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]}} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "k" , "kind" : "variable"} , "subtrees" : [ ] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]}}] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]}} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "j" , "kind" : "variable"} , "subtrees" : [ ] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]}}] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}}] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}}] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]}}] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}}] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "N" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "N" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]}]}} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "nil" , "kind" : "variable"} , "subtrees" : [ ] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "N" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]}}] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "N" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]}}] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "N" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]}}] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}}] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]}}] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]}]}}] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "∩" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "×" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]}]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "<" , "kind" : "type variable"} , "subtrees" : [ ]}]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]}]}]}}] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]}]}}] , "type" : { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]}]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "->" , "kind" : "?"} , "subtrees" : [ { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "J" , "kind" : "set"} , "subtrees" : [ ]} , { "$" : "Tree" , "root" : { "$" : "Identifier" , "literal" : "R" , "kind" : "set"} , "subtrees" : [ ]}]}]}]}}]}}'
                    stream.write "\n\n"
            else
                for parsedBlock in output.fromNearley
                    console.log("sending1", parsedBlock)
                    stream.write <| JSON.stringify(parsedBlock)
                    stream.write "\n\n"
            stream.end!

        fs.writeFileSync "/tmp/synopsis.txt" input

        stream = fs.createWriteStream "/tmp/synopsis.json"
        stream.once \open -> toStream stream

        jar.stdin.setEncoding('utf-8')
        toStream jar.stdin

    catch err
        err.message = JSON.stringify(err)
        error(err)