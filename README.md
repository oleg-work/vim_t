# T

More convenient wrapper for frequently used vim's `:term_sendkeys` terminal function.
```
:let term_buffer_id = 16
```
From:
```
:'<,'>y | call term_sendkeys(term_buffer_id,@")
```
to:
```
:'<,'>T term_buffer_id
```
