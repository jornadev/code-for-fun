import 'package:flutter/material.dart';
import 'package:code_for_fun/model/trail_model.dart';
import 'package:code_for_fun/model/lesson_model.dart';

class TrailService {
  static final List<Trail> _allTrails = [
    const Trail(
      id: 'java',
      title: 'Formação Java',
      icon: Icons.coffee,
      level: 'Intermediário',
      progress: 0.0,
      iconColor: Colors.orange,
      lessons: [
        const Lesson(
          id: 'j1',
          title: 'Módulo 1: Fundamentos',
          isCompleted: false,
          questions: [
            const Question(
              id: 'j1q1',
              text: 'O que é a JVM?',
              answers: [
                const Answer(id: 'a1', text: 'Um editor de código Java', isCorrect: false),
                const Answer(id: 'a2', text: 'Java Virtual Machine (Máquina Virtual)', isCorrect: true),
                const Answer(id: 'a3', text: 'Um tipo de café', isCorrect: false),
              ],
            ),
            const Question(
              id: 'j1q2',
              text: 'Qual palavra-chave declara uma variável que NÃO pode ser mudada?',
              answers: [
                const Answer(id: 'a1', text: 'static', isCorrect: false),
                const Answer(id: 'a2', text: 'const', isCorrect: false),
                const Answer(id: 'a3', text: 'final', isCorrect: true),
              ],
            ),
            const Question(
              id: 'j1q3',
              text: 'Qual o ponto de entrada de um programa Java?',
              answers: [
                const Answer(id: 'a1', text: 'public static void main(String[] args)', isCorrect: true),
                const Answer(id: 'a2', text: 'function start()', isCorrect: false),
                const Answer(id: 'a3', text: 'int main()', isCorrect: false),
              ],
            ),
            const Question(
              id: 'j1q4',
              text: 'Qual o operador para "igual a" (comparação)?',
              answers: [
                const Answer(id: 'a1', text: '=', isCorrect: false),
                const Answer(id: 'a2', text: '==', isCorrect: true),
                const Answer(id: 'a3', text: ':=', isCorrect: false),
              ],
            ),
            const Question(
              id: 'j1q5',
              text: 'Qual o operador para "atribuição"?',
              answers: [
                const Answer(id: 'a1', text: '=', isCorrect: true),
                const Answer(id: 'a2', text: '==', isCorrect: false),
                const Answer(id: 'a3', text: '===', isCorrect: false),
              ],
            ),
          ],
        ),
        const Lesson(
          id: 'j2',
          title: 'Módulo 2: Orientação a Objetos',
          isCompleted: false,
          questions: [
            const Question(
              id: 'j2q1',
              text: 'O que é uma Classe?',
              answers: [
                const Answer(id: 'a1', text: 'Um objeto', isCorrect: false),
                const Answer(id: 'a2', text: 'Um molde ou modelo para criar objetos', isCorrect: true),
                const Answer(id: 'a3', text: 'Uma função', isCorrect: false),
              ],
            ),
            const Question(
              id: 'j2q2',
              text: 'O que `System.out.println()` faz?',
              answers: [
                const Answer(id: 'a1', text: 'Lê dados do usuário', isCorrect: false),
                const Answer(id: 'a2', text: 'Imprime um texto no console e pula linha', isCorrect: true),
                const Answer(id: 'a3', text: 'Cria uma nova janela', isCorrect: false),
              ],
            ),
            const Question(
              id: 'j2q3',
              text: 'O que é "Herança"?',
              answers: [
                const Answer(id: 'a1', text: 'Uma classe que cria objetos', isCorrect: false),
                const Answer(id: 'a2', text: 'Uma classe que herda atributos de outra classe', isCorrect: true),
                const Answer(id: 'a3', text: 'Uma variável global', isCorrect: false),
              ],
            ),
            const Question(
              id: 'j2q4',
              text: 'O que é "Polimorfismo"?',
              answers: [
                const Answer(id: 'a1', text: 'A capacidade de ter várias formas', isCorrect: true),
                const Answer(id: 'a2', text: 'Ocultar dados internos', isCorrect: false),
                const Answer(id: 'a3', text: 'Ter muitas classes', isCorrect: false),
              ],
            ),
            const Question(
              id: 'j2q5',
              text: 'O que é "Encapsulamento"?',
              answers: [
                const Answer(id: 'a1', text: 'Agrupar dados e métodos, protegendo-os', isCorrect: true),
                const Answer(id: 'a2', text: 'Transformar um objeto em outro', isCorrect: false),
                const Answer(id: 'a3', text: 'Um tipo de loop', isCorrect: false),
              ],
            ),
          ],
        ),
        const Lesson(
          id: 'j3',
          title: 'Módulo 3: Tipos Primitivos',
          isCompleted: false,
          questions: [
            const Question(
              id: 'j3q1',
              text: 'Qual tipo de dado armazena texto?',
              answers: [
                const Answer(id: 'a1', text: 'String', isCorrect: true),
                const Answer(id: 'a2', text: 'char', isCorrect: false),
                const Answer(id: 'a3', text: 'Text', isCorrect: false),
              ],
            ),
            const Question(
              id: 'j3q2',
              text: 'Qual tipo de dado armazena "verdadeiro" ou "falso"?',
              answers: [
                const Answer(id: 'a1', text: 'bool', isCorrect: false),
                const Answer(id: 'a2', text: 'boolean', isCorrect: true),
                const Answer(id: 'a3', text: 'int', isCorrect: false),
              ],
            ),
            const Question(
              id: 'j3q3',
              text: 'Qual tipo de dado armazena números inteiros?',
              answers: [
                const Answer(id: 'a1', text: 'double', isCorrect: false),
                const Answer(id: 'a2', text: 'String', isCorrect: false),
                const Answer(id: 'a3', text: 'int', isCorrect: true),
              ],
            ),
            const Question(
              id: 'j3q4',
              text: 'Qual tipo de dado armazena números decimais?',
              answers: [
                const Answer(id: 'a1', text: 'float', isCorrect: false),
                const Answer(id: 'a2', text: 'double', isCorrect: true),
                const Answer(id: 'a3', text: 'int', isCorrect: false),
              ],
            ),
            const Question(
              id: 'j3q5',
              text: 'Qual tipo de dado armazena UM ÚNICO caractere?',
              answers: [
                const Answer(id: 'a1', text: 'String', isCorrect: false),
                const Answer(id: 'a2', text: 'char', isCorrect: true),
                const Answer(id: 'a3', text: 'byte', isCorrect: false),
              ],
            ),
          ],
        ),
        const Lesson(
          id: 'j4',
          title: 'Módulo 4: Estruturas de Controle',
          isCompleted: false,
          questions: [
            const Question(
              id: 'j4q1',
              text: 'Qual palavra-chave inicia uma condição "se"?',
              answers: [
                const Answer(id: 'a1', text: 'if', isCorrect: true),
                const Answer(id: 'a2', text: 'case', isCorrect: false),
                const Answer(id: 'a3', text: 'for', isCorrect: false),
              ],
            ),
            const Question(
              id: 'j4q2',
              text: 'Qual palavra-chave inicia um loop "enquanto"?',
              answers: [
                const Answer(id: 'a1', text: 'for', isCorrect: false),
                const Answer(id: 'a2', text: 'while', isCorrect: true),
                const Answer(id: 'a3', text: 'if', isCorrect: false),
              ],
            ),
            const Question(
              id: 'j4q3',
              text: 'Qual palavra-chave inicia um loop "para"?',
              answers: [
                const Answer(id: 'a1', text: 'while', isCorrect: false),
                const Answer(id: 'a2', text: 'loop', isCorrect: false),
                const Answer(id: 'a3', text: 'for', isCorrect: true),
              ],
            ),
            const Question(
              id: 'j4q4',
              text: 'Qual palavra-chave é usada para a condição "senão"?',
              answers: [
                const Answer(id: 'a1', text: 'or', isCorrect: false),
                const Answer(id: 'a2', text: 'else', isCorrect: true),
                const Answer(id: 'a3', text: 'then', isCorrect: false),
              ],
            ),
            const Question(
              id: 'j4q5',
              text: 'Qual o operador lógico para "OU"?',
              answers: [
                const Answer(id: 'a1', text: '&&', isCorrect: false),
                const Answer(id: 'a2', text: '||', isCorrect: true),
                const Answer(id: 'a3', text: 'OR', isCorrect: false),
              ],
            ),
          ],
        ),
        const Lesson(
          id: 'j5',
          title: 'Módulo 5: Classes e Métodos',
          isCompleted: false,
          questions: [
            const Question(
              id: 'j5q1',
              text: 'O que é um "método construtor"?',
              answers: [
                const Answer(id: 'a1', text: 'Um método para destruir objetos', isCorrect: false),
                const Answer(id: 'a2', text: 'Um método chamado ao criar um objeto', isCorrect: true),
                const Answer(id: 'a3', text: 'Um método para conectar ao banco', isCorrect: false),
              ],
            ),
            const Question(
              id: 'j5q2',
              text: 'A palavra-chave `new` é usada para...',
              answers: [
                const Answer(id: 'a1', text: 'Criar uma nova classe', isCorrect: false),
                const Answer(id: 'a2', text: 'Declarar uma variável', isCorrect: false),
                const Answer(id: 'a3', text: 'Instanciar (criar) um objeto', isCorrect: true),
              ],
            ),
            const Question(
              id: 'j5q3',
              text: 'O que a palavra-chave `static` faz?',
              answers: [
                const Answer(id: 'a1', text: 'Torna um método ou variável pertencente à classe, não ao objeto', isCorrect: true),
                const Answer(id: 'a2', text: 'Torna uma variável imutável', isCorrect: false),
                const Answer(id: 'a3', text: 'Torna um método mais rápido', isCorrect: false),
              ],
            ),
            const Question(
              id: 'j5q4',
              text: 'O que a palavra-chave `void` significa?',
              answers: [
                const Answer(id: 'a1', text: 'Que o método é privado', isCorrect: false),
                const Answer(id: 'a2', text: 'Que o método não retorna nenhum valor', isCorrect: true),
                const Answer(id: 'a3', text: 'Que o método pode dar erro', isCorrect: false),
              ],
            ),
            const Question(
              id: 'j5q5',
              text: 'Qual a diferença entre "==" e ".equals()"?',
              answers: [
                const Answer(id: 'a1', text: '"==" compara referência, .equals() compara valor', isCorrect: true),
                const Answer(id: 'a2', text: '"==" compara valor, .equals() compara referência', isCorrect: false),
                const Answer(id: 'a3', text: 'Ambos são idênticos', isCorrect: false), // <-- LINHA CORRIGIDA
              ],
            ),
          ],
        ),
      ],
    ),

    const Trail(
      id: 'python',
      title: 'Python Básico',
      icon: Icons.code,
      level: 'Iniciante',
      progress: 0.0,
      iconColor: Colors.green,
      lessons: [
        const Lesson(
          id: 'p1',
          title: 'Módulo 1: Sintaxe Básica',
          isCompleted: false,
          questions: [
            const Question(
              id: 'p1q1',
              text: 'Como se imprime "Olá" no console em Python?',
              answers: [
                const Answer(id: 'a1', text: 'console.log("Olá")', isCorrect: false),
                const Answer(id: 'a2', text: 'print("Olá")', isCorrect: true),
                const Answer(id: 'a3', text: 'echo "Olá"', isCorrect: false),
              ],
            ),
            const Question(
              id: 'p1q2',
              text: 'Qual o símbolo para comentários de uma linha em Python?',
              answers: [
                const Answer(id: 'a1', text: '//', isCorrect: false),
                const Answer(id: 'a2', text: '/*', isCorrect: false),
                const Answer(id: 'a3', text: '#', isCorrect: true),
              ],
            ),
            const Question(
              id: 'p1q3',
              text: 'Python usa chaves {} ou indentação para blocos de código?',
              answers: [
                const Answer(id: 'a1', text: 'Chaves {}', isCorrect: false),
                const Answer(id: 'a2', text: 'Indentação (espaços)', isCorrect: true),
                const Answer(id: 'a3', text: 'Ponto e vírgula ;', isCorrect: false),
              ],
            ),
            const Question(
              id: 'p1q4',
              text: 'Qual função captura a entrada de dados do usuário no console?',
              answers: [
                const Answer(id: 'a1', text: 'input()', isCorrect: true),
                const Answer(id: 'a2', text: 'read()', isCorrect: false),
                const Answer(id: 'a3', text: 'get_data()', isCorrect: false),
              ],
            ),
            const Question(
              id: 'p1q5',
              text: 'Qual função retorna o número de itens em uma lista?',
              answers: [
                const Answer(id: 'a1', text: '.size()', isCorrect: false),
                const Answer(id: 'a2', text: 'len()', isCorrect: true),
                const Answer(id: 'a3', text: '.count()', isCorrect: false),
              ],
            ),
          ],
        ),
        const Lesson(
          id: 'p2',
          title: 'Módulo 2: Variáveis e Tipos',
          isCompleted: false,
          questions: [
            const Question(
              id: 'p2q1',
              text: 'Como se cria uma lista vazia em Python?',
              answers: [
                const Answer(id: 'a1', text: 'lista = ()', isCorrect: false),
                const Answer(id: 'a2', text: 'lista = []', isCorrect: true),
                const Answer(id: 'a3', text: 'lista = {}', isCorrect: false),
              ],
            ),
            const Question(
              id: 'p2q2',
              text: 'Qual tipo de dado armazena "verdadeiro" ou "falso"?',
              answers: [
                const Answer(id: 'a1', text: 'bool (com B maiúsculo: True/False)', isCorrect: true),
                const Answer(id: 'a2', text: 'boolean (com b minúsculo: true/false)', isCorrect: false),
                const Answer(id: 'a3', text: 'number', isCorrect: false),
              ],
            ),
            const Question(
              id: 'p2q3',
              text: 'Qual tipo de dado é usado para armazenar texto?',
              answers: [
                const Answer(id: 'a1', text: 'string', isCorrect: false),
                const Answer(id: 'a2', text: 'str', isCorrect: true),
                const Answer(id: 'a3', text: 'char', isCorrect: false),
              ],
            ),
            const Question(
              id: 'p2q4',
              text: 'Qual tipo de dado é usado para números decimais?',
              answers: [
                const Answer(id: 'a1', text: 'int', isCorrect: false),
                const Answer(id: 'a2', text: 'decimal', isCorrect: false),
                const Answer(id: 'a3', text: 'float', isCorrect: true),
              ],
            ),
            const Question(
              id: 'p2q5',
              text: 'Qual o resultado de "5" + "5"?',
              answers: [
                const Answer(id: 'a1', text: '10', isCorrect: false),
                const Answer(id: 'a2', text: 'Erro', isCorrect: false),
                const Answer(id: 'a3', text: '"55"', isCorrect: true),
              ],
            ),
          ],
        ),

        const Lesson(
          id: 'p3',
          title: 'Módulo 3: Estruturas de Controle',
          isCompleted: false,
          questions: [
            const Question(
              id: 'p3q1',
              text: 'Qual palavra-chave inicia uma condição "se"?',
              answers: [
                const Answer(id: 'a1', text: 'if', isCorrect: true),
                const Answer(id: 'a2', text: 'case', isCorrect: false),
                const Answer(id: 'a3', text: 'cond', isCorrect: false),
              ],
            ),
            const Question(
              id: 'p3q2',
              text: 'Qual palavra-chave inicia um loop "enquanto"?',
              answers: [
                const Answer(id: 'a1', text: 'for', isCorrect: false),
                const Answer(id: 'a2', text: 'loop', isCorrect: false),
                const Answer(id: 'a3', text: 'while', isCorrect: true),
              ],
            ),
            const Question(
              id: 'p3q3',
              text: 'Qual palavra-chave inicia um loop "para cada item"?',
              answers: [
                const Answer(id: 'a1', text: 'for', isCorrect: true),
                const Answer(id: 'a2', text: 'each', isCorrect: false),
                const Answer(id: 'a3', text: 'while', isCorrect: false),
              ],
            ),
            const Question(
              id: 'p3q4',
              text: 'Qual palavra-chave é usada para a condição "senão se"?',
              answers: [
                const Answer(id: 'a1', text: 'else if', isCorrect: false),
                const Answer(id: 'a2', text: 'elif', isCorrect: true),
                const Answer(id: 'a3', text: 'elseif', isCorrect: false),
              ],
            ),
            const Question(
              id: 'p3q5',
              text: 'Qual o operador lógico para "E"?',
              answers: [
                const Answer(id: 'a1', text: '&&', isCorrect: false),
                const Answer(id: 'a2', text: 'AND', isCorrect: false),
                const Answer(id: 'a3', text: 'and', isCorrect: true),
              ],
            ),
          ],
        ),

        const Lesson(
          id: 'p4',
          title: 'Módulo 4: Funções',
          isCompleted: false,
          questions: [
            const Question(
              id: 'p4q1',
              text: 'Qual palavra-chave define uma função em Python?',
              answers: [
                const Answer(id: 'a1', text: 'function', isCorrect: false),
                const Answer(id: 'a2', text: 'def', isCorrect: true),
                const Answer(id: 'a3', text: 'fun', isCorrect: false),
              ],
            ),
            const Question(
              id: 'p4q2',
              text: 'Qual palavra-chave retorna um valor de uma função?',
              answers: [
                const Answer(id: 'a1', text: 'return', isCorrect: true),
                const Answer(id: 'a2', text: 'yield', isCorrect: false),
                const Answer(id: 'a3', text: 'send', isCorrect: false),
              ],
            ),
            const Question(
              id: 'p4q3',
              text: 'O que são "parâmetros" de uma função?',
              answers: [
                const Answer(id: 'a1', text: 'Variáveis locais da função', isCorrect: false),
                const Answer(id: 'a2', text: 'Valores que a função recebe', isCorrect: true),
                const Answer(id: 'a3', text: 'Valores que a função retorna', isCorrect: false),
              ],
            ),
            const Question(
              id: 'p4q4',
              text: 'Como importar a biblioteca "math"?',
              answers: [
                const Answer(id: 'a1', text: 'include math', isCorrect: false),
                const Answer(id: 'a2', text: 'import math', isCorrect: true),
                const Answer(id: 'a3', text: 'using math', isCorrect: false),
              ],
            ),
            const Question(
              id: 'p4q5',
              text: 'O que é uma função "lambda"?',
              answers: [
                const Answer(id: 'a1', text: 'Uma função anônima e pequena', isCorrect: true),
                const Answer(id: 'a2', text: 'Uma função que não retorna nada', isCorrect: false),
                const Answer(id: 'a3', text: 'Uma função de outra biblioteca', isCorrect: false),
              ],
            ),
          ],
        ),

        const Lesson(
          id: 'p5',
          title: 'Módulo 5: Estruturas de Dados',
          isCompleted: false,
          questions: [
            const Question(
              id: 'p5q1',
              text: 'Qual estrutura armazena pares de "chave: valor" desordenados?',
              answers: [
                const Answer(id: 'a1', text: 'list', isCorrect: false),
                const Answer(id: 'a2', text: 'dict (dicionário)', isCorrect: true),
                const Answer(id: 'a3', text: 'tuple (tupla)', isCorrect: false),
              ],
            ),
            const Question(
              id: 'p5q2',
              text: 'Qual estrutura é uma lista IMUTÁVEL (não pode ser alterada)?',
              answers: [
                const Answer(id: 'a1', text: 'list', isCorrect: false),
                const Answer(id: 'a2', text: 'dict', isCorrect: false),
                const Answer(id: 'a3', text: 'tuple (tupla)', isCorrect: true),
              ],
            ),
            const Question(
              id: 'p5q3',
              text: 'Qual estrutura armazena itens únicos e desordenados?',
              answers: [
                const Answer(id: 'a1', text: 'set (conjunto)', isCorrect: true),
                const Answer(id: 'a2', text: 'list', isCorrect: false),
                const Answer(id: 'a3', text: 'dict', isCorrect: false),
              ],
            ),
            const Question(
              id: 'p5q4',
              text: 'Como se acessa o primeiro item de uma lista `frutas`?',
              answers: [
                const Answer(id: 'a1', text: 'frutas(0)', isCorrect: false),
                const Answer(id: 'a2', text: 'frutas[0]', isCorrect: true),
                const Answer(id: 'a3', text: 'frutas.first()', isCorrect: false),
              ],
            ),
            const Question(
              id: 'p5q5',
              text: 'Qual método adiciona um item ao final de uma lista?',
              answers: [
                const Answer(id: 'a1', text: '.add()', isCorrect: false),
                const Answer(id: 'a2', text: '.push()', isCorrect: false),
                const Answer(id: 'a3', text: '.append()', isCorrect: true),
              ],
            ),
          ],
        ),
      ],
    ),

    const Trail(
      id: 'data_structures',
      title: 'Estrutura de dados',
      icon: Icons.share,
      level: 'Intermediário',
      progress: 0.0,
      iconColor: Colors.blue,
      lessons: [

        const Lesson(
          id: 'd1',
          title: 'Módulo 1: Conceitos Básicos',
          isCompleted: false,
          questions: [
            const Question(
              id: 'd1q1',
              text: 'O que é um Array (Vetor)?',
              answers: [
                const Answer(id: 'a1', text: 'Uma coleção ordenada de elementos', isCorrect: true),
                const Answer(id: 'a2', text: 'Uma coleção desordenada', isCorrect: false),
                const Answer(id: 'a3', text: 'Um único valor', isCorrect: false),
              ],
            ),
            const Question(
              id: 'd1q2',
              text: 'Qual estrutura segue o princípio "FIFO" (Primeiro a Entrar, Primeiro a Sair)?',
              answers: [
                const Answer(id: 'a1', text: 'Pilha (Stack)', isCorrect: false),
                const Answer(id: 'a2', text: 'Fila (Queue)', isCorrect: true),
                const Answer(id: 'a3', text: 'Árvore (Tree)', isCorrect: false),
              ],
            ),
            const Question(
              id: 'd1q3',
              text: 'Qual estrutura segue o princípio "LIFO" (Último a Entrar, Primeiro a Sair)?',
              answers: [
                const Answer(id: 'a1', text: 'Pilha (Stack)', isCorrect: true),
                const Answer(id: 'a2', text: 'Fila (Queue)', isCorrect: false),
                const Answer(id: 'a3', text: 'Array', isCorrect: false),
              ],
            ),
            const Question(
              id: 'd1q4',
              text: 'O que é "Complexidade de Algoritmo"?',
              answers: [
                const Answer(id: 'a1', text: 'O quão difícil é escrever o código', isCorrect: false),
                const Answer(id: 'a2', text: 'O tempo e espaço que um algoritmo usa', isCorrect: true),
                const Answer(id: 'a3', text: 'O número de bugs no código', isCorrect: false),
              ],
            ),
            const Question(
              id: 'd1q5',
              text: 'O que significa a notação "Big O", como O(n)?',
              answers: [
                const Answer(id: 'a1', text: 'Mede o "pior caso" de performance', isCorrect: true),
                const Answer(id: 'a2', text: 'Mede o "melhor caso" de performance', isCorrect: false),
                const Answer(id: 'a3', text: 'Mede o número de linhas de código', isCorrect: false),
              ],
            ),
          ],
        ),

        const Lesson(
          id: 'd2',
          title: 'Módulo 2: Listas Ligadas',
          isCompleted: false,
          questions: [
            const Question(
              id: 'd2q1',
              text: 'O que um "nó" (node) em uma lista ligada armazena?',
              answers: [
                const Answer(id: 'a1', text: 'Apenas o dado', isCorrect: false),
                const Answer(id: 'a2', text: 'O dado e uma referência para o próximo nó', isCorrect: true),
                const Answer(id: 'a3', text: 'Apenas a referência para o próximo nó', isCorrect: false),
              ],
            ),
            const Question(
              id: 'd2q2',
              text: 'O que é o "head" de uma lista ligada?',
              answers: [
                const Answer(id: 'a1', text: 'O último nó', isCorrect: false),
                const Answer(id: 'a2', text: 'O nó do meio', isCorrect: false),
                const Answer(id: 'a3', text: 'O primeiro nó', isCorrect: true),
              ],
            ),
            const Question(
              id: 'd2q3',
              text: 'Qual a principal vantagem de uma Lista Ligada sobre um Array?',
              answers: [
                const Answer(id: 'a1', text: 'Acesso mais rápido aos elementos por índice', isCorrect: false),
                const Answer(id: 'a2', text: 'Inserção e remoção de elementos é mais eficiente', isCorrect: true),
                const Answer(id: 'a3', text: 'Ocupa menos memória', isCorrect: false),
              ],
            ),
            const Question(
              id: 'd2q4',
              text: 'O que é uma Lista Duplamente Ligada?',
              answers: [
                const Answer(id: 'a1', text: 'Uma lista com dois "heads"', isCorrect: false),
                const Answer(id: 'a2', text: 'Um nó aponta para o próximo e para o anterior', isCorrect: true),
                const Answer(id: 'a3', text: 'Uma lista que só aceita 2 tipos de dados', isCorrect: false),
              ],
            ),
            const Question(
              id: 'd2q5',
              text: 'O que o último nó de uma lista ligada simples aponta?',
              answers: [
                const Answer(id: 'a1', text: 'Para o "head"', isCorrect: false),
                const Answer(id: 'a2', text: 'Para ele mesmo', isCorrect: false),
                const Answer(id: 'a3', text: 'Para "null" (nulo)', isCorrect: true),
              ],
            ),
          ],
        ),

        const Lesson(
          id: 'd3',
          title: 'Módulo 3: Pilhas (Stacks)',
          isCompleted: false,
          questions: [
            const Question(
              id: 'd3q1',
              text: 'Uma Pilha (Stack) usa qual princípio?',
              answers: [
                const Answer(id: 'a1', text: 'LIFO (Último a Entrar, Primeiro a Sair)', isCorrect: true),
                const Answer(id: 'a2', text: 'FIFO (Primeiro a Entrar, Primeiro a Sair)', isCorrect: false),
                const Answer(id: 'a3', text: 'Aleatório', isCorrect: false),
              ],
            ),
            const Question(
              id: 'd3q2',
              text: 'Qual operação adiciona um item ao topo da pilha?',
              answers: [
                const Answer(id: 'a1', text: 'pop()', isCorrect: false),
                const Answer(id: 'a2', text: 'push()', isCorrect: true),
                const Answer(id: 'a3', text: 'peek()', isCorrect: false),
              ],
            ),
            const Question(
              id: 'd3q3',
              text: 'Qual operação remove o item do topo da pilha?',
              answers: [
                const Answer(id: 'a1', text: 'pop()', isCorrect: true),
                const Answer(id: 'a2', text: 'push()', isCorrect: false),
                const Answer(id: 'a3', text: 'remove()', isCorrect: false),
              ],
            ),
            const Question(
              id: 'd3q4',
              text: 'Qual operação "espia" o item do topo sem removê-lo?',
              answers: [
                const Answer(id: 'a1', text: 'pop()', isCorrect: false),
                const Answer(id: 'a2', text: 'view()', isCorrect: false),
                const Answer(id: 'a3', text: 'peek()', isCorrect: true),
              ],
            ),
            const Question(
              id: 'd3q5',
              text: 'O botão "Voltar" do navegador é um exemplo de qual estrutura?',
              answers: [
                const Answer(id: 'a1', text: 'Fila (Queue)', isCorrect: false),
                const Answer(id: 'a2', text: 'Pilha (Stack)', isCorrect: true),
                const Answer(id: 'a3', text: 'Árvore (Tree)', isCorrect: false),
              ],
            ),
          ],
        ),

        const Lesson(
          id: 'd4',
          title: 'Módulo 4: Filas (Queues)',
          isCompleted: false,
          questions: [
            const Question(
              id: 'd4q1',
              text: 'Uma Fila (Queue) usa qual princípio?',
              answers: [
                const Answer(id: 'a1', text: 'LIFO (Último a Entrar, Primeiro a Sair)', isCorrect: false),
                const Answer(id: 'a2', text: 'FIFO (Primeiro a Entrar, Primeiro a Sair)', isCorrect: true),
                const Answer(id: 'a3', text: 'Aleatório', isCorrect: false),
              ],
            ),
            const Question(
              id: 'd4q2',
              text: 'A operação de adicionar um item ao fim da fila é chamada de:',
              answers: [
                const Answer(id: 'a1', text: 'Enqueue', isCorrect: true),
                const Answer(id: 'a2', text: 'Dequeue', isCorrect: false),
                const Answer(id: 'a3', text: 'Push', isCorrect: false),
              ],
            ),
            const Question(
              id: 'd4q3',
              text: 'A operação de remover um item do início da fila é chamada de:',
              answers: [
                const Answer(id: 'a1', text: 'Enqueue', isCorrect: false),
                const Answer(id: 'a2', text: 'Dequeue', isCorrect: true),
                const Answer(id: 'a3', text: 'Pop', isCorrect: false),
              ],
            ),
            const Question(
              id: 'd4q4',
              text: 'Uma fila de impressão de impressora é um exemplo de:',
              answers: [
                const Answer(id: 'a1', text: 'Pilha (Stack)', isCorrect: false),
                const Answer(id: 'a2', text: 'Fila (Queue)', isCorrect: true),
                const Answer(id: 'a3', text: 'Hash Table', isCorrect: false),
              ],
            ),
            const Question(
              id: 'd4q5',
              text: 'Em uma fila, onde os novos elementos são inseridos?',
              answers: [
                const Answer(id: 'a1', text: 'No início (front)', isCorrect: false),
                const Answer(id: 'a2', text: 'No fim (rear/back)', isCorrect: true),
                const Answer(id: 'a3', text: 'No meio', isCorrect: false),
              ],
            ),
          ],
        ),

        const Lesson(
          id: 'd5',
          title: 'Módulo 5: Árvores e Hashes',
          isCompleted: false,
          questions: [
            const Question(
              id: 'd5q1',
              text: 'O que é o "nó raiz" (root node) de uma árvore?',
              answers: [
                const Answer(id: 'a1', text: 'O nó do topo, que não tem "pai"', isCorrect: true),
                const Answer(id: 'a2', text: 'Qualquer nó que não tem "filhos"', isCorrect: false),
                const Answer(id: 'a3', text: 'O nó com o maior valor', isCorrect: false),
              ],
            ),
            const Question(
              id: 'd5q2',
              text: 'O que são "nós folha" (leaf nodes)?',
              answers: [
                const Answer(id: 'a1', text: 'O nó raiz', isCorrect: false),
                const Answer(id: 'a2', text: 'Nós que não possuem "filhos"', isCorrect: true),
                const Answer(id: 'a3', text: 'Os nós do primeiro nível', isCorrect: false),
              ],
            ),
            const Question(
              id: 'd5q3',
              text: 'Em uma Árvore Binária, quantos filhos um nó pode ter no máximo?',
              answers: [
                const Answer(id: 'a1', text: 'Um', isCorrect: false),
                const Answer(id: 'a2', text: 'Dois', isCorrect: true),
                const Answer(id: 'a3', text: 'Quantos quiser', isCorrect: false),
              ],
            ),
            const Question(
              id: 'd5q4',
              text: 'O que é uma "Hash Table" (Tabela Hash)?',
              answers: [
                const Answer(id: 'a1', text: 'Uma estrutura que armazena dados em ordem', isCorrect: false),
                const Answer(id: 'a2', text: 'Uma estrutura que usa pares de chave-valor', isCorrect: true),
                const Answer(id: 'a3', text: 'Uma árvore binária', isCorrect: false),
              ],
            ),
            const Question(
              id: 'd5q5',
              text: 'O que é uma "colisão" em uma Hash Table?',
              answers: [
                const Answer(id: 'a1', text: 'Quando duas chaves geram o mesmo índice', isCorrect: true),
                const Answer(id: 'a2', text: 'Quando a tabela está cheia', isCorrect: false),
                const Answer(id: 'a3', text: 'Um erro no código', isCorrect: false),
              ],
            ),
          ],
        ),
      ],
    ),
  ];


  static List<Trail> getRecommendedTrails() {
    return _allTrails;
  }


  static List<Trail> getInProgressTrails() {
    return _allTrails.where((trail) => trail.progress > 0.0).toList();
  }
}