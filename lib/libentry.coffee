root = exports ? this

class _EntryLib

    getSummaries: (entries) ->
        entries.map (e) ->
            text = $('<div>').html( e.text ).text()
            text = (text.substring(0,200) + '...') if text.length > 204
            {text: text, title: e.title}

@EntryLib = new _EntryLib()
