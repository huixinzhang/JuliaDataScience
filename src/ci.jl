"""
    write_thanks_page()

Thanks page for when people sign up for email updates.
"""
function write_thanks_page()
    text = """
        <!DOCTYPE html>
        <html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
        <body>
            <div style="margin-top: 40px; font-size: 40px; text-align: center;">
                <br>
                <br>
                <br>
                <div style="font-weight: bold;">
                    Thank you
                </div>
                <br>
                <div>
                    You successfully signed up for email updates.
                </div>
                <br>
                <br>
                <div style="margin-bottom: 300px; font-size: 24px">
                    <a href="/">Click here</a> to go back to the homepage.
                </div>
            </div>
        </body>
        """
    path = joinpath(BUILD_DIR, "thanks.html")
    write(path, text)
    return path
end

"""
    build()

This method is called during CI.
"""
function build()
    println("Building JDS")
    write_thanks_page()
    fail_on_error = true
    gen(; fail_on_error)
    build_all(; fail_on_error)
end
