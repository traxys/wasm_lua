(module
  (type (;0;) (func (param i32)))
  (type (;1;) (func (param i32 i32)))
  (type (;2;) (func))
  (import "env" "putchar" (func $putchar (type 0)))
  (func $_ZN6simple7print_s17hf806b6684ebcb0b4E (type 1) (param i32 i32)
    (local i32)
    block  ;; label = @1
      local.get 1
      i32.eqz
      br_if 0 (;@1;)
      local.get 0
      i32.load8_u
      call $putchar
      local.get 1
      i32.const 1
      i32.eq
      br_if 0 (;@1;)
      local.get 1
      i32.const -1
      i32.add
      local.set 2
      local.get 0
      i32.const 1
      i32.add
      local.set 1
      loop  ;; label = @2
        local.get 1
        i32.load8_u
        call $putchar
        local.get 1
        i32.const 1
        i32.add
        local.set 1
        local.get 2
        i32.const -1
        i32.add
        local.tee 2
        br_if 0 (;@2;)
      end
    end)
  (func $_start (type 2)
    (local i32 i32)
    global.get 0
    i32.const 16
    i32.sub
    local.tee 0
    global.set 0
    local.get 0
    i32.const 1
    i32.store8 offset=15
    local.get 0
    i32.const 15
    i32.add
    local.set 1
    block  ;; label = @1
      block  ;; label = @2
        local.get 0
        i32.load8_u offset=15
        i32.eqz
        br_if 0 (;@2;)
        i32.const 1048576
        i32.const 11
        call $_ZN6simple7print_s17hf806b6684ebcb0b4E
        br 1 (;@1;)
      end
      i32.const 1048587
      i32.const 8
      call $_ZN6simple7print_s17hf806b6684ebcb0b4E
    end
    local.get 0
    i32.const 16
    i32.add
    global.set 0)
  (table (;0;) 1 1 funcref)
  (memory (;0;) 17)
  (global (;0;) (mut i32) (i32.const 1048576))
  (global (;1;) i32 (i32.const 1048595))
  (global (;2;) i32 (i32.const 1048595))
  (export "memory" (memory 0))
  (export "_start" (func $_start))
  (export "__data_end" (global 1))
  (export "__heap_base" (global 2))
  (data (;0;) (i32.const 1048576) "Hello worldnot that"))
