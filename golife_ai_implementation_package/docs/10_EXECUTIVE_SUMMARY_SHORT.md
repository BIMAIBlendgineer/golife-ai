# Resumen ejecutivo corto — GoLife AI

GoLife AI es una app móvil que une hábitos, tareas, semana, dinero, armario y despensa. La novedad no es añadir un chatbot a cada módulo, sino crear una IA que vea conexiones entre áreas de la vida diaria y proponga misiones pequeñas, explicables y seguras.

Ejemplo:

> “Hoy evita comprar comida. Tienes ingredientes suficientes, gastaste más esta semana en comida fuera y tienes una tarea corta pendiente. Misión: cocinar en 20 minutos y cerrar una tarea de 10 minutos.”

La app se construye sobre ideas de repositorios open-source existentes, pero debe crear una arquitectura nueva:

- Flutter como app principal;
- LifeGraph como columna vertebral de eventos;
- FastAPI como AI Gateway;
- LangGraph para orquestar decisiones;
- OpenRouter como proveedor inicial reemplazable;
- privacidad por dominio;
- explicación obligatoria para cada sugerencia.

El MVP debe empezar pequeño: tareas, hábitos, gastos simples, despensa manual y misión diaria IA.
