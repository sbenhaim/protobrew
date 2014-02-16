@filepickerApiKey = 'AjmU2eDdtRDyMpagSeV7rz'
@filepickerStoreEndpoint = "https://www.filepicker.io/api/store/S3?key=#{@filepickerApiKey}"

Router.map ->

    result = false
    
    @route 'upload',
        path: 'images'
        where: 'server'
        action: ->
            path = @request.files.file.path
            name = @request.files.file.name
            type = @request.files.file.type


            Fiber = Npm.require('fibers')
            Future = Npm.require('fibers/future')
            wait = Future.wait;

            request = Npm.require('request')
            FormData = Npm.require('form-data')
            fs = Npm.require('fs')


            form = new FormData();
            form.append( "fileUpload", fs.createReadStream( path ) )
            form.append( "filename", name )

            theBody = false

            post = ( callback ) ->
                form.getLength (err, length) ->

                    return requestCallback(err) if (err)

                    r = request.post(
                        @filepickerStoreEndpoint,
                        (err, res, body) ->
                            callback( null, body )
                    )

                    r._form = form;
                    r.setHeader('content-length', length)

            result = (Future.wrap(post))().wait()
            result = JSON.parse( result )


            @response.writeHead(200, {'Content-Type': 'text/json'})
            @response.end( JSON.stringify( { filelink: result.url, filename: name } ) )

