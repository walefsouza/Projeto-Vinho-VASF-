# 🍷 Sistema de Automação Industrial - VINHOVASF

> **Projeto de Circuitos Digitais Sequenciais em FPGA**

Este repositório contém os artefatos de desenvolvimento (código-fonte, documentação e apresentação) de um controlador digital para uma linha de produção de vinhos, desenvolvido como requisito da disciplina **TEC498 - Projeto de Circuitos Digitais** da Universidade Estadual de Feira de Santana (UEFS).

## 📋 Sobre o Projeto

O objetivo deste projeto foi modernizar o processo de envase do **Instituto do Vinho do Vale do São Francisco (VINHOVASF)**, substituindo o controle manual por um sistema digital automatizado e síncrono.

A solução foi implementada na placa de desenvolvimento **DE10-Lite (Intel MAX 10)** utilizando a linguagem de descrição de hardware **Verilog**. O sistema coordena sensores e atuadores simulados para gerenciar o transporte, enchimento, vedação e controle de qualidade das garrafas.

### 🚀 Principais Funcionalidades

* **Arquitetura Modular:** Controle distribuído entre 4 Máquinas de Estados Finitos (FSM).
* **Abordagem Híbrida:** Uso estratégico de modelos **Moore** (para estabilidade de atuadores) e **Mealy** (para responsividade da interface humana).
* **Segurança de Intertravamento:** Lógica de segurança na FSM do Motor para impedir acionamentos indevidos.
* **Gestão de Estoque:** Contadores com carga paralela para monitoramento e reposição automática de rolhas.
* **Contagem Hierárquica:** Sistema de contadores em cascata para rastreamento de unidades e lotes (dúzias).
* **Interface Rica:** Feedback visual completo via LEDs e Displays de 7 Segmentos (conversão Binário-BCD).

## 🛠️ Tecnologias e Ferramentas

* **Hardware:** FPGA DE10-Lite (Altera/Intel MAX 10 10M50DAF484C7G).
* **Linguagem:** Verilog HDL (IEEE 1364-2005).
* **IDE / Síntese:** Quartus Prime Lite Edition.
* **Simulação:** ModelSim / Waveform Editor.

## 📂 Estrutura do Repositório

```text
.
├── src/                  # Códigos fonte em Verilog (.v)
│   ├── top_level/        # Módulo principal (vinhovasfTOP.v)
│   ├── fsm/              # Máquinas de Estados (Motor, Enchimento, Vedação, Qualidade)
│   ├── datapath/         # Contadores e Dispensador
│   └── utils/            # Divisor de Clock, Debouncers, Conversores BCD
├── docs/                 # Documentação
│   └── Relatorio_Tecnico_Final.pdf
├── presentation/         # Material de Apresentação
│   └── Slides_Defesa.pdf
├── simulation/           # Arquivos de simulação e waveforms
└── README.md
