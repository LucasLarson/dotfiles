<?php

if(foo)
{
    $values = array( // indent only after arrays
        "raw",
        "foo", // single line comment
        "bar", /* no trailing comma on next */
        "fud"
    );
    if(foo): // colon-terminated
        foo();
        bar();
    else:
        bar(42);
        if(foo) /* indent just next */
            bar();
    endif;
}
else
{
    if(foo) {
        foo();
        bar();
    } else {
        if(foo) {
            foo();
            bar();
            switch(foo):
                case 31:
                {
                    bar();
                    fud();
                }
                break;

                case 42:
                bar();
                break;
            endswitch;
        }
        else {
            for($i = 0; $i < 42; $i++):
                bar();
                baz();
                for($i = 0; $i < 42; $i++)
                    bar();
            endfor;
        }
    }
}

array(
    '1' => '1',
    '#1' => 1,
    // # in previous line shoud not make this line be indented
);
$form['#after_build'] = array('some_string');
// # in previous line shoud not make this line be indented

# No indent after comment lines
bar();
// No indent after comment lines
baz();

?>