class _EntryLib

    getEntryPath: (wikiName, entryName) ->
        "/wikis/" + wikiName + "/entry/" + entryName

    getSummaries: (entries) ->
        entries.map (e) ->
            text = $('<div>').html( e.text ).text()
            text = (text.substring(0,200) + '...') if text.length > 204
            {text: text, title: e.title}

    redactorButtons: [ 'html', '|', 'formatting', '|', 'bold', 'italic', 'deleted', '|',
                       'unorderedlist', 'orderedlist', 'outdent', 'indent', '|',
                       'image', 'file', 'table', 'link', '|',
                       'fontcolor', 'backcolor', '|', 'alignment', '|', 'horizontalrule' ]

    filepickerKey: 'AjmU2eDdtRDyMpagSeV7rz'

    initRedactor: ($el, html, plugins) ->
        $el.redactor
            plugins: plugins
            imageUpload: '/upload'
            clipboardUploadUrl: '/upload'
            # linebreaks: true # buggy - insert link on last line, hit enter to break,
            # with cursor on newline try to insert link (modal only show edit of previous link)
            buttons: this.redactorButtons
            focus: true
            autoresize: true
            minHeight: 100 #pixels
            fileUpload: '/upload'
            removeEmptyTags: false
            # filepicker: (callback) =>
            #     filepicker.setKey(@filepickerKey)
            #     filepicker.pick({}, (file) ->
            #         filepicker.store(file, {location:"S3", path: Meteor.userId() + "/" + file.filename },
            #         (file) ->
            #             file.filelink = file.url
            #             callback( file )))
        # set redactor content - false so that it doesn't remove empty <p> tags
        $el.redactor('set', html , false);
                            


@EntryLib = new _EntryLib()
