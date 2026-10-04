**UNIVERSIDADE DE MOGI DAS CRUZES**

**ENGENHARIA DE SOFTWARE**

Leandro Nunes RGM: 11251102018

Leticia Brito RGM: 11251103781

Marcelo Lourenço RGM:  11251101144

Marina Herrera RGM: 11251100552

Nicolas Domingues RGM: 11251102442

Desenvolvimento de biossensor para detectar desidratação ou exaustão do trabalhador rural exposto ao calor.

Mogi das Cruzes \- SP

2026

Leandro Nunes

Leticia Brito

Marcelo Lourenço

Marina Herrera

Nicolas Domingues

Desenvolvimento de biossensor para detectar desidratação ou exaustão do trabalhador rural exposto ao calor.

Projeto de desenvolvimento acadêmico apresentado ao Curso Superior de Engenharia de Software da Universidade de Mogi das Cruzes, orientado pelas Prof.as Alessandra Martins e Silvia Martini, como requisito parcial da disciplina de Engenharia de Software.

Mogi das Cruzes \- SP

2026

Sumário

[1\. BRIEFING	4](#1.-briefing)

[1.1 Tema	4](#1.1-tema)

[1.2 TIPO DE SERVIÇO/PRODUTO	4](#1.2-tipo-de-serviço/produto)

[1.3 OBJETIVO	4](#1.3-objetivo)

[1.3.1 OBJETIVOS ESPECÍFICOS	4](#1.3.1-objetivos-específicos)

[1.4 PÚBLICO-ALVO	5](#1.4-público-alvo)

[1.5 PRINCIPAIS DIFERENCIAIS	5](#1.5-principais-diferenciais)

[1.6 METODOLOGIA E PROPOSTAS DE DESENVOLVIMENTO PRÁTICO	6](#1.6-metodologia-e-propostas-de-desenvolvimento-prático)

[1.7 RESULTADOS ESPERADOS	6](#1.7-resultados-esperados)

[2\. PARTICIPANTES	6](#2.-participantes)

[3\.  KANBAM COM SCRUM	7](#3.-kanban-com-scrum)

[4\. SPRINT	8](#4.-sprint)

[4.1 Primeira/Segunda Semana	8](#heading=h.xye3hllh2v6c)

# 1\. BRIEFING {#1.-briefing}

## 1.1 Tema {#1.1-tema}

Desenvolvimento de biossensor para detectar desidratação ou exaustão do trabalhador rural exposto ao calor.

## 1.2 TIPO DE SERVIÇO/PRODUTO {#1.2-tipo-de-serviço/produto}

	Saúde ocupacional e segurança do trabalho.

## 1.3 OBJETIVO {#1.3-objetivo}

	Criar um sistema que utilize biossensor e tecnologia de monitoramento fisiológico para:

* Monitorar sinais fisiológicos do trabalhador rural;  
* Detectar indicadores relacionados à desidratação;  
* Identificar sinais de exaustão e estresse térmico;  
* Avaliar as condições do trabalhador durante a exposição ao calor;  
* Emitir alertas quando forem identificadas condições de risco;  
* Registrar e armazenar os dados coletados pelo biossensor;  
* Auxiliar na prevenção de problemas de saúde relacionados ao calor;  
* Fornecer informações para acompanhamento das condições de saúde ocupacional do trabalhador.

## 1.3.1 OBJETIVOS ESPECÍFICOS {#1.3.1-objetivos-específicos}

* Monitorar os sinais fisiológicos do trabalhador

	Permitir que o biossensor realize a coleta de dados fisiológicos do trabalhador rural durante sua exposição a condições de calor, utilizando sensores adequados para o monitoramento de parâmetros relacionados ao estado físico do indivíduo.

* Detectar indicadores de desidratação

   	Durante o período de utilização do dispositivo, o sistema deverá analisar os dados coletados pelos sensores e identificar alterações que possam estar relacionados à desidratação do trabalhador, permitindo o acompanhamento de sua condição fisiológica.

* Identificar sinais de exaustão térmica

  	O sistema deverá avaliar os parâmetros fisiológicos monitorados pelo biossensor com o objetivo de identificar possíveis sinais associados à exaustão térmica decorrente da exposição prolongada ao calor e da realização de atividades físicas.

* Emitir alertas de risco

  	A partir da identificação de alterações nos parâmetros monitorados, o sistema deverá emitir alertas ao trabalhador ou ao responsável pelo acompanhamento, indicando a necessidade de atenção às condições físicas do trabalhador.

* Registrar e armazenar os dados coletados

  	O sistema deverá registrar as informações obtidas pelo biossensor durante o período de monitoramento, permitindo o armazenamento e a consulta dos dados para acompanhamento da condição fisiológica do trabalhador.

* Analisar os dados fisiológicos

  	Os dados coletados pelo biossensor deverão ser processados pelo sistema para identificar padrões e alterações nos parâmetros fisiológicos, possibilitando uma análise das condições do trabalhador durante a sua exposição ao calor.

* Auxiliar na prevenção de riscos relacionados ao calor

  	O sistema deverá fornecer informações que auxiliem na identificação antecipada de situações de risco relacionados à desidratação e à exaustão térmica, contribuindo para a adoção de medidas preventivas durante a jornada de trabalho.

* Disponibilizar informações para acompanhamento

  	O sistema deverá apresentar os dados e alertas de forma simples e compreensível, permitindo que o trabalhador ou responsável pelo acompanhamento. 

* Informar o nível de bateria do dispositivo

  	O sistema deverá informar o nível de bateria disponível no biossensor, permitindo que o usuário tenha conhecimento da necessidade de recarga antes ou durante a utilização do dispositivo.

 

## 1.4 PÚBLICO-ALVO {#1.4-público-alvo}

	Trabalhadores rurais.

## 1.5 PRINCIPAIS DIFERENCIAIS {#1.5-principais-diferenciais}

* Monitoramento em tempo real de sinais relacionados à desidratação e exaustão pelo calor.  
* Tecnologia portátil e de baixo custo, adequada à rotina do trabalhador rural.  
* Análise dos dados e emissão de alertas para auxiliar na prevenção de riscos à saúde durante a exposição ao calor.

## 1.6 METODOLOGIA E PROPOSTAS DE DESENVOLVIMENTO PRÁTICO {#1.6-metodologia-e-propostas-de-desenvolvimento-prático}

* Frontend: Flutter.  
* Biblioteca UI sugerida: FL Chart.  
* Backend: Dart.  
* Banco de Dados: PostgreSQL e MongoDB.  
* Infraestrutura: AWS, Azure ou Google Cloud.  
* APIs e Inteligência Artificial. (a definir)

## 1.7 RESULTADOS ESPERADOS {#1.7-resultados-esperados}

	A princípio, desejamos desenvolver um protótipo funcional capaz de identificar sinais de desidratação ou exaustão causados pela exposição ao calor e, futuramente, aprimorá-lo para utilização e comercialização no ambiente de trabalho rural.

# 2\. PARTICIPANTES {#2.-participantes}

| Equipe | Funções |
| ----- | ----- |
| Marcelo Lourenço | PO (Product Owner)  |
| Leandro Nunes  | Scrum Master  |
| Leticia Brito | Desenvolvimento  |
| Marina Herrera | Programador (Desenvolvimento)   |
| Nicolas Domingues | Analista de Sistemas (Desenvolvimento)   |

# 3\. KANBAN COM SCRUM {#3.-kanban-com-scrum}

## 

| TABELA SCRUM \- 1° SEMANA |  |  |  |
| :---: | :---: | :---: | :---: |
| **Backlog** | **To Do** | **Doing** | **Done** |
| Briefing  | Escolha da Metodologia | Briefing  | Divisão de Cargos |
| Divisão de Cargos |  | Modelagem do Logotipo |  |
| Escolha da Metodologia |  |  |  |
| Modelagem do Logotipo |  |  |  |

## 

| TABELA SCRUM \- 2° SEMANA |  |  |  |
| :---: | ----- | :---: | :---: |
| **Backlog** | **To Do** | **Doing** | **Done** |
| Briefing |  | Briefing |  Escolha dos Sensores |
| Escolha da Metodologia |  | Escolha da Metodologia | Modelagem do Logotipo |
| Escolha dos Sensores |  |  |  |
| Modelagem do Logotipo |  |  |  |

## 

| TABELA SCRUM \- 3° SEMANA |  |  |  |
| :---: | :---: | :---: | :---: |
| **Backlog** | **To Do** | **Doing** | **Done** |
| Briefing | Protótipo | Modelagem do Documento | Briefing |
| Escolha da Metodologia |  |  | Escolha da Metodologia |
| Protótipo |  |  |  |
| Modelagem do Documento |  |  |  |

## 

| TABELA SCRUM \- 4° SEMANA |  |  |  |
| :---: | :---: | :---: | ----- |
| **Backlog** | **To Do** | **Doing** | **Done** |
| Protótipo | Levantamento de Requisitos | Protótipo | Modelagem do Documento |
| Levantamento de Requisitos |  |  |  |
| Modelagem do Documento |  |  | teste pra ver se atualiza no github |

# 4\. SPRINT {#4.-sprint}

| SPRINT |  |  |  |  |  |
| :---: | :---: | :---: | :---: | :---: | :---: |
|   | **SEGUNDA** | **TERÇA** | **QUARTA** | **QUINTA** | **SEXTA** |
| **1ª Semana** |  |  |  |  |  |
|  |  |  |  |  |  |
|  |  |  |  |  |   |
|  |  |  |  |  |   |
|  |  |  |  |  |   |
|  |  |  |  |  |  |
| **2ª Semana** |  |  |  |  |  |
|  |  |  |  |  |  |
|  |  |  |  |  |  |
|  |  |  |  |  |  |
|  |  |  |  |  |   |
|  |  |  |  |  |  |

## 

| SPRINT |  |  |  |  |  |
| :---: | :---: | :---: | :---: | :---: | :---: |
|   | **SEGUNDA** | **TERÇA** | **QUARTA** | **QUINTA** | **SEXTA** |
| **3ª Semana** |  |  |  |  |  |
|  |  |  |  |  |  |
|  |  |  |  |  |  |
|  |  |  |  |  |  |
|  |  |  |  |  |   |
|  |  |  |  |   |  |
| **4ªsemana** |  |  |  |  |  |
|  |  |  |  |  |  |
|  |  |  |  |  |  |
|  |  |  |  |  |  |
|  |  |  |  |  |  |
|  |  |   |   |   |   |

