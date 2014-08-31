angular.module \main
  ..factory \render, -> ret = do
    color: d3.scale.category20!
    toggle: -> # TODO: use message
      s = angular.element(\body)scope!
      s.mvote.toggle it
    draw: (data,node) ->
      len = data.length
      yscale = d3.scale.linear!domain [0, len] .range [30 570]
      xscale = d3.scale.linear!domain [0, d3.max(data.map(->it.value))] .range [30 770]
      d3.select(node).selectAll \rect.bar .data data
        ..exit!remove!
        ..enter!append \rect
          ..attr do
            class: \bar
            x: (v,i) -> xscale 0
            y: (v,i) -> yscale i
            width: 0
            height: 0
            fill: 'rgba(0,0,0,0)'
            cursor: 'pointer'
          ..on \click (d,i) ~> @toggle d
      d3.select(node).selectAll \rect.bar
        ..transition!duration 1000
          ..attr do
            x: (v,i) -> xscale 0
            y: (v,i) -> yscale i
            width: (v,i) -> xscale v.value
            height: (v,i) -> yscale(i + 1) - yscale(i) - 5
            fill: (d,i) ~> @color d.name

      d3.select(node).selectAll \g.text .data data
        ..exit!remove!
        ..enter!append \g .attr \class, \text
          ..each (d,i) ->
            text-init = do
              x: (v) -> xscale 0
              y: (v) -> yscale i
              "font-size": 0
              "text-anchor": \middle
              "dominant-baseline": \central
              fill: 'rgba(255,255,255,0)'
              stroke: 'rgba(0,0,0,0)'
              cursor: 'pointer'
              "stroke-linecap": \round
              "stroke-linejoin": \round
              "stroke-width": 7

            d3.select @ .append \text
              ..attr text-init
              ..attr \class, \stroke
              ..text -> "#{d.name} ( #{d.value} )"
            d3.select @ .append \text
              ..attr text-init
              ..attr \class, \fill
              ..text -> "#{d.name} ( #{d.value} )"
              ..on \click -> ret.toggle d

      d3.select(node).selectAll \g.text
        ..each (d,i) ->
          text-target = do
            x: -> xscale(d.value / 2) >? 50
            y: -> ( yscale(i + 1) + yscale(i) ) / 2
            "font-size": 20

          d3.select @ .selectAll \text.stroke
            ..transition!duration 1000
              ..attr text-target
              ..attr \stroke, 'rgba(0,0,0,1)'
              ..text -> "#{d.name} ( #{d.value} )"
          d3.select @ .selectAll \text.fill
            ..transition!duration 1000
              ..attr text-target
              ..attr \fill, 'rgba(255,255,255,1)'
              ..text -> "#{d.name} ( #{d.value} )"
