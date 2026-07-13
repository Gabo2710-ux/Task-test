const express = require('express');
const cors = require('cors');
const fs = require('fs');
const jsonServer = require('json-server');

const app = express();
const PORT = 3000;

const router = jsonServer.router('db.json');
const middlewares = jsonServer.defaults();

app.use(cors());
app.use(express.json());

// Helper to get db state
const getDb = () => router.db.getState();

// Custom Home Page
app.get('/', (req, res) => {
  const db = getDb();
  const tasksCount = Array.isArray(db.tasks) ? db.tasks.length : 0;
  const messagesCount = Array.isArray(db.messages) ? db.messages.length : 0;
  const transitionsCount = Array.isArray(db.tasks) ? db.tasks.reduce((sum, task) => sum + (Array.isArray(task.status_history) ? task.status_history.length : 0), 0) : 0;

  res.send(`
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Task Manager API</title>
      <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; line-height: 1.6; color: #333; max-width: 800px; margin: 0 auto; padding: 2rem; }
        h1 { color: #2c3e50; border-bottom: 2px solid #eee; padding-bottom: 0.5rem; }
        h2 { color: #34495e; margin-top: 2rem; }
        ul { list-style-type: none; padding: 0; }
        li { padding: 0.5rem 0; border-bottom: 1px solid #f5f5f5; }
        a { color: #3498db; text-decoration: none; font-weight: bold; }
        a:hover { text-decoration: underline; }
        .count { background-color: #e8f4f8; padding: 0.2rem 0.6rem; border-radius: 12px; font-size: 0.9em; color: #2980b9; margin-left: 0.5rem; }
      </style>
    </head>
    <body>
      <h1>Task Manager Mock API</h1>
      <p>The mock server is actively running and ready to accept requests.</p>
      
      <h2>Available Resources</h2>
      <ul>
        <li><a href="/api/tasks">/api/tasks</a> <span class="count">${tasksCount} items</span></li>
        <li><a href="/messages">/messages</a> <span class="count">${messagesCount} items</span></li>
        <li><a href="/status_transitions">/status_transitions</a> <span class="count">${transitionsCount} items</span></li>
      </ul>
      
      <h2>Documentation</h2>
      <p>This API provides simulated endpoints for task listing, chat messaging, and status transitions for the Flutter application.</p>
    </body>
    </html>
  `);
});

// Custom route for GET /status_transitions
app.get('/status_transitions', (req, res) => {
  try {
    const db = getDb();
    const tasks = db.tasks || [];
    let allTransitions = [];
    
    // Extract and flatten all status histories
    tasks.forEach(task => {
      if (Array.isArray(task.status_history)) {
        // Optionally inject task_id into each transition for context
        const transitionsWithTask = task.status_history.map(t => ({
          ...t,
          task_id: task.id
        }));
        allTransitions = allTransitions.concat(transitionsWithTask);
      }
    });

    // Sort by created_at descending
    allTransitions.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));

    res.json(allTransitions);
  } catch (error) {
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Custom route for GET /api/tasks with pagination and search
app.get('/api/tasks', (req, res) => {
  try {
    const db = getDb();
    let tasks = db.tasks || [];

    // Filter by search
    if (req.query.search) {
      const s = req.query.search.toLowerCase();
      tasks = tasks.filter(t => 
        (t.title && t.title.toLowerCase().includes(s)) ||
        (t.description && t.description.toLowerCase().includes(s)) ||
        (t.reference && t.reference.toLowerCase().includes(s))
      );
    }

    // Filter by status
    if (req.query.status) {
      tasks = tasks.filter(t => t.status === req.query.status);
    }

    // Pagination
    const page = parseInt(req.query.page) || 1;
    const perPage = parseInt(req.query.per_page) || 20;
    const total = tasks.length;
    
    const start = (page - 1) * perPage;
    const end = start + perPage;
    const paginatedTasks = tasks.slice(start, end);

    res.json({
      data: paginatedTasks,
      meta: {
        current_page: page,
        per_page: perPage,
        total: total,
        last_page: Math.ceil(total / perPage) || 1
      }
    });
  } catch (error) {
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// POST /api/tasks
app.post('/api/tasks', (req, res) => {
  try {
    const db = getDb();
    const newTask = req.body;
    
    db.tasks = db.tasks || [];
    db.tasks.unshift(newTask); // Add to beginning
    
    router.db.setState(db);
    router.db.write();
    
    res.status(201).json({ data: newTask });
  } catch (error) {
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// GET /api/tasks/:id
app.get('/api/tasks/:id', (req, res) => {
  try {
    const db = getDb();
    const task = db.tasks.find(t => t.id === req.params.id);
    if (!task) {
      return res.status(404).json({ error: 'Not found' });
    }
    res.json({ data: task });
  } catch (error) {
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// POST /api/tasks/:id/status-transitions
app.post('/api/tasks/:id/status-transitions', (req, res) => {
  try {
    const db = getDb();
    const taskId = req.params.id;
    const taskIndex = db.tasks.findIndex(t => t.id === taskId);
    
    if (taskIndex === -1) {
      return res.status(404).json({ error: 'Not found' });
    }

    const task = db.tasks[taskIndex];
    const { status, note, image_url, image } = req.body;

    const errors = {};
    if (!status || status === task.status) {
      errors.status = ["The new status must be different from the current status."];
    }
    
    // Support multipart simulated 'image' boolean/string or 'image_url' JSON
    const hasEvidence = note || image_url || image;
    if (!hasEvidence) {
      errors.evidence = ["A note or an image is required."];
    }

    if (Object.keys(errors).length > 0) {
      return res.status(400).json({
        error: {
          code: "VALIDATION_ERROR",
          message: "The status transition could not be created.",
          fields: errors
        }
      });
    }

    // Create transition
    const transition = {
      id: `transition_${Date.now()}`,
      previous_status: task.status,
      new_status: status,
      note: note || null,
      image_url: image_url || (image ? "https://picsum.photos/400/300" : null),
      created_at: new Date().toISOString(),
      created_by: {
        id: "user_001",
        name: "Alex Morgan",
        avatar_url: "https://example.test/images/users/user_001.jpg"
      }
    };

    // Update task
    task.status = status;
    task.updated_at = new Date().toISOString();
    task.status_history = task.status_history || [];
    task.status_history.push(transition);
    
    db.tasks[taskIndex] = task;
    router.db.setState(db);
    router.db.write();

    res.json({
      data: {
        task: {
          id: task.id,
          reference: task.reference,
          title: task.title,
          status: task.status,
          updated_at: task.updated_at
        },
        transition: transition
      }
    });
  } catch (error) {
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// GET /api/tasks/:id/messages
app.get('/api/tasks/:id/messages', (req, res) => {
  try {
    const db = getDb();
    const taskId = req.params.id;
    const task = db.tasks.find(t => t.id === taskId);
    
    if (!task) {
      return res.status(404).json({ error: 'Not found' });
    }

    const messages = (db.messages || []).filter(m => m.task_id === taskId);
    
    res.json({
      data: messages,
      meta: {
        participants: task.assignees || []
      }
    });
  } catch (error) {
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// POST /api/tasks/:id/messages
app.post('/api/tasks/:id/messages', (req, res) => {
  try {
    const db = getDb();
    const taskId = req.params.id;
    const task = db.tasks.find(t => t.id === taskId);
    
    if (!task) {
      return res.status(404).json({ error: 'Not found' });
    }

    const { content } = req.body;
    if (!content || content.trim().length === 0) {
      return res.status(400).json({
        error: {
          code: "VALIDATION_ERROR",
          message: "The message could not be sent.",
          fields: {
            content: ["The message content is required."]
          }
        }
      });
    }

    const newMessage = {
      id: `message_${Date.now()}`,
      task_id: taskId,
      type: "text",
      content: content.trim(),
      created_at: new Date().toISOString(),
      sender: {
        id: "user_001",
        name: "Alex Morgan",
        avatar_url: "https://example.test/images/users/user_001.jpg"
      }
    };

    db.messages = db.messages || [];
    db.messages.push(newMessage);
    router.db.setState(db);
    router.db.write();

    res.json({ data: newMessage });

    // Simulate bot reply if there are other participants
    const otherParticipants = (task.assignees || []).filter(p => p.id !== 'user_001');
    if (otherParticipants.length > 0) {
      setTimeout(() => {
        const currentDb = getDb();
        const randomParticipant = otherParticipants[Math.floor(Math.random() * otherParticipants.length)];
        
        const mockReplies = [
          "Got it! I'll keep an eye on it.",
          "Perfect, thanks for letting me know.",
          "I'm heading there right now.",
          "Do you need any help with that?",
          "Awesome, let me check that for you.",
          "Sounds like a plan!",
          "I'll notify the rest of the team."
        ];
        
        const botMessage = {
          id: `message_${Date.now()}`,
          task_id: taskId,
          type: "text",
          content: mockReplies[Math.floor(Math.random() * mockReplies.length)],
          created_at: new Date().toISOString(),
          sender: randomParticipant
        };
        
        currentDb.messages.push(botMessage);
        router.db.setState(currentDb);
        router.db.write();
      }, 2000);
    }
  } catch (error) {
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// For all other routes, use json-server router

app.use(middlewares);
app.use(router);

app.listen(PORT, () => {
  console.log(`Mock server running at http://localhost:${PORT}`);
});
