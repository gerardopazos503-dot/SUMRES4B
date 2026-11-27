`default_nettype none

// ============================================================
// MODULO PRINCIPAL TINY TAPEOUT
// SUMADOR - RESTADOR DE 4 BITS
// ============================================================

module tt_um_SUMADOR_RESTADOR (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // Entradas
    wire [3:0] A;
    wire [3:0] B;
    wire BTN;

    assign A = {ui_in[4], ui_in[5], ui_in[6], ui_in[7]};
    assign B = {ui_in[0], ui_in[1], ui_in[2], ui_in[3]};
    assign BTN = uio_in[0];

    // Resultado
    wire [4:0] RESULT;

    // Instancia del sumador-restador
    SUMADOR_RESTADOR U1 (
        .A(A),
        .B(B),
        .BTN(BTN),
        .S(RESULT)
    );

    // Salidas
    assign uo_out[7:3] = {
        RESULT[0],
        RESULT[1],
        RESULT[2],
        RESULT[3],
        RESULT[4]
    };
    
    assign uo_out[2:0] = 3'b000;

    // Pines bidireccionales sin utilizar
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    // Señales no utilizadas: diseño combinacional
    wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule


// ============================================================
// MODULO SUMADOR_RESTADOR
// Calcula suma y resta simultaneamente.
// BTN selecciona el resultado.
// ============================================================

module SUMADOR_RESTADOR (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire       BTN,
    output wire [4:0] S
);

    // Instancia del sumador completo
    // y del restador independiente

    wire [4:0] suma_result;
    wire [4:0] resta_result;
    wire [4:0] C;

    // Acarreo inicial
    assign C[0] = 1'b0;

    // Cuatro sumadores completos conectados en cascada
    genvar i;

    generate
        for (i = 0; i < 4; i = i + 1) begin : GEN_SUMADOR

            SUMA1 SUM (
                .Ci(C[i]),
                .A(A[i]),
                .B(B[i]),
                .Co(C[i+1]),
                .S(suma_result[i])
            );

        end
    endgenerate

    // Acarreo final
    assign suma_result[4] = C[4];

    // Restador independiente
    RESTA REST (
        .A(A),
        .B(B),
        .S(resta_result)
    );

    // Selector de operación
    // BTN = 0: suma
    // BTN = 1: resta

    assign S = (BTN == 1'b0) ? suma_result : resta_result;

endmodule


// ============================================================
// MODULO SUMA1
// SUMADOR COMPLETO DE UN BIT
// ============================================================

module SUMA1 (
    input  wire Ci,
    input  wire A,
    input  wire B,
    output wire Co,
    output wire S
);

    // Bit de suma
    assign S = Ci ^ A ^ B;

    // Acarreo de salida
    assign Co = (Ci & A) |
                (Ci & B) |
                (A & B)  |
                (A & B & Ci);

endmodule


// ============================================================
// MODULO RESTA
// RESTADOR DE 4 BITS
// ============================================================

module RESTA (
    input  wire [3:0] A,
    input  wire [3:0] B,
    output wire [4:0] S
);

    // Resta utilizando representacion en complemento a dos
    assign S = $signed({1'b0, A}) - $signed({1'b0, B});

endmodule

`default_nettype wire
